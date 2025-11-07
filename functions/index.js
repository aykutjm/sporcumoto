/**
 * Firebase Cloud Functions for Sporcum
 * Arka planda çalışan zamanlanmış görevler
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const fetch = require('node-fetch');

admin.initializeApp();

/**
 * ✅ ZAMANLANMIŞ MESAJ GÖNDERİMİ
 * Her 5 dakikada bir çalışır ve gönderilmesi gereken mesajları kontrol eder
 */
exports.scheduledMessageSender = functions.pubsub
    .schedule('every 5 minutes')
    .timeZone('Europe/Istanbul')
    .onRun(async (context) => {
        console.log('📅 Zamanlanmış mesaj kontrolü başladı...');
        
        try {
            const db = admin.firestore();
            const now = new Date();
            
            // Gönderilmesi gereken mesajları bul
            // status: 'scheduled', scheduledTime <= now
            const scheduledMessagesRef = db.collection('scheduledMessages')
                .where('status', '==', 'scheduled')
                .where('scheduledTime', '<=', now);
            
            const snapshot = await scheduledMessagesRef.get();
            
            if (snapshot.empty) {
                console.log('✅ Gönderilecek zamanlanmış mesaj yok.');
                return null;
            }
            
            console.log(`📨 ${snapshot.size} adet mesaj gönderilecek...`);
            
            let successCount = 0;
            let failCount = 0;
            
            // Her mesajı sırayla işle
            for (const doc of snapshot.docs) {
                const message = doc.data();
                
                try {
                    // WhatsApp cihaz bilgilerini al
                    const deviceDoc = await db.collection('whatsappDevices')
                        .doc(message.deviceId)
                        .get();
                    
                    if (!deviceDoc.exists) {
                        throw new Error('WhatsApp cihazı bulunamadı');
                    }
                    
                    const device = deviceDoc.data();
                    
                    // Evolution API ile mesaj gönder
                    const result = await sendWhatsAppMessageViaAPI(
                        device.evolutionUrl,
                        device.apiKey,
                        device.instanceName,
                        message.phoneNumber,
                        message.messageText
                    );
                    
                    if (result.success) {
                        // Başarılı - durumu güncelle
                        await doc.ref.update({
                            status: 'sent',
                            sentAt: admin.firestore.FieldValue.serverTimestamp(),
                            result: 'success'
                        });
                        
                        // sentMessages koleksiyonuna ekle
                        await db.collection('sentMessages').add({
                            recipientName: message.recipientName,
                            phone: message.phoneNumber,
                            message: message.messageText,
                            sentAt: admin.firestore.FieldValue.serverTimestamp(),
                            instanceName: device.instanceName,
                            status: 'sent',
                            type: message.messageType || 'scheduled',
                            clubId: message.clubId
                        });
                        
                        successCount++;
                        console.log(`✅ Mesaj gönderildi: ${message.recipientName}`);
                    } else {
                        throw new Error(result.error || 'Mesaj gönderilemedi');
                    }
                    
                } catch (error) {
                    console.error(`❌ Mesaj gönderme hatası: ${message.recipientName}`, error);
                    
                    // Hata durumunu kaydet
                    await doc.ref.update({
                        status: 'failed',
                        failedAt: admin.firestore.FieldValue.serverTimestamp(),
                        error: error.message,
                        retryCount: admin.firestore.FieldValue.increment(1)
                    });
                    
                    failCount++;
                }
                
                // Rate limiting - mesajlar arası bekleme
                await new Promise(resolve => setTimeout(resolve, 5000)); // 5 saniye
            }
            
            console.log(`✅ Toplu gönderim tamamlandı. Başarılı: ${successCount}, Başarısız: ${failCount}`);
            return { success: successCount, failed: failCount };
            
        } catch (error) {
            console.error('❌ Zamanlanmış mesaj gönderimi hatası:', error);
            return null;
        }
    });

/**
 * ✅ ÖDEME HATIRLATMALARI (Günlük)
 * Her gün saat 09:00'da çalışır
 */
exports.dailyPaymentReminders = functions.pubsub
    .schedule('0 9 * * *')
    .timeZone('Europe/Istanbul')
    .onRun(async (context) => {
        console.log('💰 Günlük ödeme hatırlatmaları başladı...');
        
        try {
            const db = admin.firestore();
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            
            // Kulüpleri al
            const clubsSnapshot = await db.collection('clubs').get();
            
            for (const clubDoc of clubsSnapshot.docs) {
                const clubId = clubDoc.id;
                const club = clubDoc.data();
                
                console.log(`📊 ${club.name} için ödeme kontrolleri yapılıyor...`);
                
                // Bu kulübün ayarlarını al
                const settingsDoc = await db.collection('clubs').doc(clubId).collection('settings').doc('general').get();
                const settings = settingsDoc.exists ? settingsDoc.data() : {};
                
                // Otomatik hatırlatma kapalıysa atla
                if (settings.autoPaymentReminders === false) {
                    console.log(`⏭️ ${club.name} için otomatik hatırlatmalar kapalı`);
                    continue;
                }
                
                // Bu kulübün preRegistrations'larını al
                const preRegsSnapshot = await db.collection('preRegistrations')
                    .where('clubId', '==', clubId)
                    .get();
                
                let reminderCount = 0;
                
                for (const preRegDoc of preRegsSnapshot.docs) {
                    const preReg = preRegDoc.data();
                    
                    if (!preReg.paymentSchedule || !Array.isArray(preReg.paymentSchedule)) {
                        continue;
                    }
                    
                    // Vadesi geçmiş ödemeleri kontrol et
                    for (const payment of preReg.paymentSchedule) {
                        if (payment.status !== 'pending') continue;
                        
                        const dueDate = new Date(payment.dueDate);
                        const daysDiff = Math.floor((today - dueDate) / (1000 * 60 * 60 * 24));
                        
                        // Vadesi geçmiş ve hatırlatma günü gelmiş mi?
                        // Her 7 günde bir hatırlatma gönder
                        if (daysDiff > 0 && daysDiff % 7 === 0) {
                            // Mesajı zamanla
                            await schedulePaymentReminder(db, clubId, preReg, payment);
                            reminderCount++;
                        }
                    }
                }
                
                console.log(`✅ ${club.name} için ${reminderCount} hatırlatma zamanlandı`);
            }
            
            return { status: 'completed' };
            
        } catch (error) {
            console.error('❌ Ödeme hatırlatmaları hatası:', error);
            return null;
        }
    });

/**
 * ✅ DOĞUM GÜNÜ MESAJLARI (Günlük)
 * Her gün saat 08:00'de çalışır
 */
exports.dailyBirthdayMessages = functions.pubsub
    .schedule('0 8 * * *')
    .timeZone('Europe/Istanbul')
    .onRun(async (context) => {
        console.log('🎂 Günlük doğum günü mesajları başladı...');
        
        try {
            const db = admin.firestore();
            const today = new Date();
            const todayMonth = today.getMonth() + 1; // 1-12
            const todayDay = today.getDate(); // 1-31
            
            // Tüm üyeleri al
            const membersSnapshot = await db.collection('members').get();
            
            let birthdayCount = 0;
            
            for (const memberDoc of membersSnapshot.docs) {
                const member = memberDoc.data();
                
                if (!member.DogumTarihi) continue;
                
                const birthDate = new Date(member.DogumTarihi);
                const birthMonth = birthDate.getMonth() + 1;
                const birthDay = birthDate.getDate();
                
                // Bugün doğum günü mü?
                if (birthMonth === todayMonth && birthDay === todayDay) {
                    // Mesajı zamanla
                    await scheduleBirthdayMessage(db, member);
                    birthdayCount++;
                }
            }
            
            console.log(`✅ ${birthdayCount} doğum günü mesajı zamanlandı`);
            return { birthdayCount };
            
        } catch (error) {
            console.error('❌ Doğum günü mesajları hatası:', error);
            return null;
        }
    });

/**
 * Helper: WhatsApp mesajı gönder
 */
async function sendWhatsAppMessageViaAPI(evolutionUrl, apiKey, instanceName, phoneNumber, message) {
    try {
        // Telefon numarasını formatla
        let formattedPhone = phoneNumber.replace(/\D/g, '');
        if (formattedPhone.startsWith('0')) {
            formattedPhone = '90' + formattedPhone.substring(1);
        } else if (!formattedPhone.startsWith('90')) {
            formattedPhone = '90' + formattedPhone;
        }
        
        const response = await fetch(`${evolutionUrl}/message/sendText/${instanceName}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'apikey': apiKey
            },
            body: JSON.stringify({
                number: `${formattedPhone}@s.whatsapp.net`,
                text: message
            })
        });
        
        if (response.ok) {
            return { success: true };
        } else {
            const errorData = await response.json();
            return { success: false, error: errorData.message || 'API hatası' };
        }
        
    } catch (error) {
        return { success: false, error: error.message };
    }
}

/**
 * Helper: Ödeme hatırlatması zamanla
 */
async function schedulePaymentReminder(db, clubId, preReg, payment) {
    // Mesaj şablonunu al
    const templatesDoc = await db.collection('clubs').doc(clubId).collection('settings').doc('messageTemplates').get();
    const templates = templatesDoc.exists ? templatesDoc.data() : {};
    
    let message = templates.overduePayment?.text || 'Sayın {AD_SOYAD}, {TUTAR} TL tutarındaki ödemenizin vadesi geçmiştir. Lütfen en kısa sürede ödeme yapınız.';
    
    // Değişkenleri değiştir
    message = message.replace(/{AD_SOYAD}/g, preReg.parentName || preReg.studentName);
    message = message.replace(/{TUTAR}/g, payment.amount.toLocaleString('tr-TR'));
    message = message.replace(/{TARIH}/g, payment.dueDate);
    
    // Default cihazı al
    const devicesSnapshot = await db.collection('whatsappDevices')
        .where('clubId', '==', clubId)
        .where('status', '==', 'connected')
        .limit(1)
        .get();
    
    if (devicesSnapshot.empty) {
        console.warn(`⚠️ ${clubId} için bağlı WhatsApp cihazı yok`);
        return;
    }
    
    const device = devicesSnapshot.docs[0];
    
    // Zamanlanmış mesaj oluştur (15 dakika sonra gönderilmek üzere)
    const scheduledTime = new Date(Date.now() + 15 * 60 * 1000);
    
    await db.collection('scheduledMessages').add({
        clubId: clubId,
        deviceId: device.id,
        recipientName: preReg.parentName || preReg.studentName,
        phoneNumber: preReg.phone,
        messageText: message,
        messageType: 'payment-reminder',
        scheduledTime: scheduledTime,
        status: 'scheduled',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        retryCount: 0
    });
}

/**
 * Helper: Doğum günü mesajı zamanla
 */
async function scheduleBirthdayMessage(db, member) {
    // Mesaj şablonunu al
    const templatesDoc = await db.collection('clubs').doc(member.clubId).collection('settings').doc('messageTemplates').get();
    const templates = templatesDoc.exists ? templatesDoc.data() : {};
    
    let message = templates.birthday?.text || '🎂 Mutlu yıllar {AD_SOYAD}! Doğum gününüzü kutlar, nice mutlu yıllar dileriz!';
    
    // Değişkenleri değiştir
    const name = member.studentName || member.parentName || 'Değerli üyemiz';
    message = message.replace(/{AD_SOYAD}/g, name);
    message = message.replace(/{AD}/g, name.split(' ')[0]);
    
    // Default cihazı al
    const devicesSnapshot = await db.collection('whatsappDevices')
        .where('clubId', '==', member.clubId)
        .where('status', '==', 'connected')
        .limit(1)
        .get();
    
    if (devicesSnapshot.empty) {
        console.warn(`⚠️ ${member.clubId} için bağlı WhatsApp cihazı yok`);
        return;
    }
    
    const device = devicesSnapshot.docs[0];
    
    // Zamanlanmış mesaj oluştur (30 dakika sonra gönderilmek üzere)
    const scheduledTime = new Date(Date.now() + 30 * 60 * 1000);
    
    await db.collection('scheduledMessages').add({
        clubId: member.clubId,
        deviceId: device.id,
        recipientName: name,
        phoneNumber: member.Telefon,
        messageText: message,
        messageType: 'birthday',
        scheduledTime: scheduledTime,
        status: 'scheduled',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        retryCount: 0
    });
}

/**
 * ✅ BULUTFON API PROXY
 * CORS sorununu çözmek için Bulutfon API'ye proxy görevi görür
 */
exports.bulutfonProxy = functions.https.onRequest(async (req, res) => {
    // CORS headers ekle
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    
    // Preflight request
    if (req.method === 'OPTIONS') {
        res.status(204).send('');
        return;
    }
    
    try {
        // API key'i query parameter veya header'dan al
        const apiKey = req.query.apikey || req.get('X-API-Key');
        
        if (!apiKey) {
            res.status(401).json({ error: 'API Key gerekli' });
            return;
        }
        
        console.log('📞 Bulutfon API proxy çağrısı...');
        
        // Tarih aralığı belirle - Son 90 gün
        const endDate = new Date();
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - 90); // Son 90 gün
        
        const startDateStr = startDate.toISOString().split('T')[0]; // YYYY-MM-DD
        const endDateStr = endDate.toISOString().split('T')[0];
        
        console.log(`📅 Tarih aralığı: ${startDateStr} - ${endDateStr}`);
        
        // Bulutfon API'ye istek yap - API key ve tarih aralığı ile
        const apiUrl = `https://api.bulutfon.com/v2/cdr/list?apikey=${apiKey}&start_date=${startDateStr}&end_date=${endDateStr}&limit=500`;
        console.log('🔗 API URL:', apiUrl.replace(apiKey, 'XXX')); // API key'i loglamadan
        
        const response = await fetch(apiUrl, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });
        
        if (!response.ok) {
            const errorText = await response.text();
            console.error('❌ Bulutfon API hatası:', response.status, errorText);
            res.status(response.status).json({ 
                error: `Bulutfon API hatası: ${response.status}`,
                details: errorText
            });
            return;
        }
        
        const data = await response.json();
        const recordCount = Array.isArray(data) ? data.length : (data.cdrs?.length || data.data?.length || 0);
        
        console.log('✅ Bulutfon API başarılı, kayıt sayısı:', recordCount);
        console.log('📦 Response yapısı:', JSON.stringify(data).substring(0, 500)); // İlk 500 karakter
        
        // Başarılı response
        res.status(200).json(data);
        
    } catch (error) {
        console.error('❌ Bulutfon proxy hatası:', error);
        res.status(500).json({ 
            error: 'Proxy hatası',
            message: error.message 
        });
    }
});

/**
 * ✅ BULUTFON SES KAYDI PROXY
 * Ses kayıtlarını CORS sorununu çözerek alır
 */
exports.bulutfonRecordingProxy = functions.https.onRequest(async (req, res) => {
    // CORS headers ekle
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    
    // Preflight request
    if (req.method === 'OPTIONS') {
        res.status(204).send('');
        return;
    }
    
    try {
        // API key ve UUID'yi query parameter'dan al
        const apiKey = req.query.apikey;
        const uuid = req.query.uuid;
        
        if (!apiKey) {
            res.status(401).json({ error: 'API Key gerekli' });
            return;
        }
        
        if (!uuid) {
            res.status(400).json({ error: 'UUID gerekli' });
            return;
        }
        
        console.log(`🎧 Bulutfon ses kaydı proxy çağrısı - UUID: ${uuid}`);
        
        // Bulutfon API'den ses kaydını al
        // Farklı endpoint formatlarını dene
        const apiUrl = `https://api.bulutfon.com/v2/cdr/${uuid}/recording?apikey=${apiKey}`;
        console.log('🔗 Recording API URL:', apiUrl.replace(apiKey, 'XXX'));
        
        const response = await fetch(apiUrl, {
            method: 'GET',
            headers: {
                'Accept': 'audio/mpeg'
            }
        });
        
        if (!response.ok) {
            console.error('❌ Bulutfon recording API hatası:', response.status);
            
            // Eğer 404 ise, kayıt yok demektir
            if (response.status === 404) {
                res.status(404).json({ 
                    error: 'Ses kaydı bulunamadı',
                    message: 'Bu görüşme için ses kaydı mevcut değil veya kaydedilmemiş olabilir'
                });
                return;
            }
            
            res.status(response.status).json({ 
                error: `Bulutfon API hatası: ${response.status}`
            });
            return;
        }
        
        // Ses dosyasını binary olarak al ve geri döndür
        const buffer = await response.buffer();
        
        console.log(`✅ Ses kaydı alındı - Boyut: ${buffer.length} bytes`);
        
        // Content-Type'ı audio/mpeg olarak ayarla
        res.set('Content-Type', 'audio/mpeg');
        res.set('Content-Length', buffer.length.toString());
        res.status(200).send(buffer);
        
    } catch (error) {
        console.error('❌ Bulutfon recording proxy hatası:', error);
        res.status(500).json({ 
            error: 'Proxy hatası',
            message: error.message 
        });
    }
});

