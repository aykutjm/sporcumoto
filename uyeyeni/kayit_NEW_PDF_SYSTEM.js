// ====================================================================
// YENİ METIN BAZLI PDF RENDERING SİSTEMİ
// ====================================================================
// Bu dosyayı kayit.html'e entegre edeceğiz
// html2canvas yerine jsPDF'nin html() metodunu kullanıyor
// Satır sonları, paragraflar ve sayfalama doğru çalışıyor
// Her sayfada imza bloğu var
// ====================================================================

async function createPdf_NEW(data) {
    try {
        console.log('🚀 ===== YENİ METIN BAZLI PDF RENDERING MOTORU =====');
        const { jsPDF } = window.jspdf;
        
        // ✅ İmza bilgilerini hazırla
        const signatureData = {
            image: data.signature,
            name: data.Ad_Soyad,
            date: new Date(data.timestamp).toLocaleString('tr-TR', {
                year: 'numeric',
                month: 'long',
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
            })
        };
        
        // ✅ Sözleşme HTML'ini hazırla
        let fullContractHTML;
        if (window.contractTemplate) {
            console.log('📄 Admin panelden yüklenen sözleşme kullanılıyor');
            fullContractHTML = replacePlaceholders(
                window.contractTemplate, 
                data, 
                clubData, 
                currentPreRegistration.paymentSchedule
            );
        } else {
            console.log('📄 Varsayılan sözleşme kullanılıyor');
            const defaultSections = getContractSections(clubData, data, currentPreRegistration.paymentSchedule);
            fullContractHTML = defaultSections.join('\n\n');
        }
        
        console.log('📄 Sözleşme hazırlandı:', fullContractHTML.length, 'karakter');
        
        // ✅ Başlık bilgisi
        const headerTitle = pageHeaderTitle || clubData?.name || 'Spor Kulübü';
        
        // ✅ <hr> tag'lerini CSS sayfa sonlarına çevir
        fullContractHTML = fullContractHTML.replace(/<hr\s*\/?>/gi, '<div style="page-break-before: always;"></div>');
        
        // ✅ Tam HTML dokümant oluştur - CSS ile sayfalama kontrolü
        const fullHtmlDocument = `
        <!DOCTYPE html>
        <html lang="tr">
        <head>
            <meta charset="UTF-8">
            <style>
                /* ===== PDF İÇİN SAYFA AYARLARI ===== */
                @page {
                    size: A4;
                    margin: 20mm 15mm 25mm 15mm; /* Üst, Sağ, Alt, Sol */
                }
                
                /* ===== TEMEL STİLLER ===== */
                * {
                    margin: 0;
                    padding: 0;
                    box-sizing: border-box;
                }
                
                body {
                    font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif;
                    font-size: 11pt;
                    line-height: 1.6;
                    color: #1f2937;
                    background: white;
                }
                
                /* ===== BAŞLIKLAR ===== */
                h1, h2, h3, h4, h5, h6 {
                    page-break-after: avoid; /* Başlıktan sonra sayfa sonu olmasın */
                    page-break-inside: avoid; /* Başlık bölünmesin */
                    margin-top: 12pt;
                    margin-bottom: 8pt;
                }
                
                h1 {
                    font-size: 18pt;
                    font-weight: bold;
                    color: #667eea;
                    text-align: center;
                    border-bottom: 2pt solid #667eea;
                    padding-bottom: 8pt;
                    margin-bottom: 16pt;
                }
                
                h4 {
                    font-size: 12pt;
                    font-weight: bold;
                    color: #374151;
                }
                
                h3, h5 {
                    font-size: 11pt;
                    font-weight: 600;
                    color: #4b5563;
                }
                
                /* ===== PARAGRAFLAR ===== */
                p {
                    margin: 6pt 0;
                    text-align: justify;
                    line-height: 1.7;
                    orphans: 3; /* Min 3 satır sayfa altında kalabilir */
                    widows: 3; /* Min 3 satır yeni sayfaya geçebilir */
                }
                
                strong, b {
                    font-weight: bold;
                    color: #111827;
                }
                
                /* ===== LİSTELER ===== */
                ul, ol {
                    margin: 8pt 0 8pt 20pt;
                    line-height: 1.8;
                    page-break-inside: avoid; /* Liste bölünmesin */
                }
                
                li {
                    margin: 4pt 0;
                }
                
                /* ===== TABLOLAR ===== */
                table {
                    width: 100%;
                    border-collapse: collapse;
                    margin: 12pt 0;
                    font-size: 9pt;
                    page-break-inside: avoid; /* Tablo bölünmesin */
                }
                
                th, td {
                    border: 1pt solid #d1d5db;
                    padding: 6pt 5pt;
                    text-align: left;
                }
                
                th {
                    background-color: #f3f4f6;
                    font-weight: bold;
                    color: #374151;
                }
                
                td {
                    background-color: #ffffff;
                }
                
                /* ===== SAYFA SONLARI ===== */
                .page-break {
                    page-break-before: always;
                }
                
                /* ===== HEADER (İLK SAYFA) ===== */
                .contract-header {
                    text-align: center;
                    margin-bottom: 20pt;
                    page-break-after: avoid;
                }
                
                /* ===== İÇERİK ===== */
                .contract-content {
                    margin-bottom: 40pt; /* İmza için alan bırak */
                }
                
                /* ===== İMZA BLOĞU (HER SAYFADA) ===== */
                .signature-container {
                    position: fixed;
                    bottom: 0;
                    left: 0;
                    right: 0;
                    padding: 10pt 15mm;
                    border-top: 1pt solid #e5e7eb;
                    background: white;
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                }
                
                .signature-box {
                    display: inline-block;
                    text-align: center;
                    padding: 8pt;
                    background: #f9fafb;
                    border: 1pt solid #e5e7eb;
                    border-radius: 6pt;
                }
                
                .signature-box img {
                    width: 100pt;
                    height: 50pt;
                    border: 1pt solid #d1d5db;
                    border-radius: 3pt;
                    background: white;
                }
                
                .signature-box p {
                    margin: 4pt 0 0 0;
                    font-size: 8pt;
                    color: #4b5563;
                }
                
                /* ===== SAYFA NUMARASI ===== */
                .page-number {
                    position: fixed;
                    bottom: 10pt;
                    right: 15mm;
                    font-size: 9pt;
                    color: #6b7280;
                }
                
                /* Print optimization */
                @media print {
                    body {
                        -webkit-print-color-adjust: exact;
                        print-color-adjust: exact;
                    }
                }
            </style>
        </head>
        <body>
            <!-- ===== ANA BAŞLIK ===== -->
            <div class="contract-header">
                <h1>${headerTitle} Üyelik Sözleşmesi</h1>
            </div>
            
            <!-- ===== SÖZLEŞME İÇERİĞİ ===== -->
            <div class="contract-content">
                ${fullContractHTML}
            </div>
            
            <!-- ===== İMZA BLOĞU (HER SAYFADA GÖRÜNECEK) ===== -->
            <div class="signature-container">
                <div class="signature-box">
                    <img src="${signatureData.image}" alt="İmza" />
                    <p><strong>${signatureData.name}</strong></p>
                    <p>${signatureData.date}</p>
                </div>
                <div class="page-number">
                    <!-- Sayfa numarası jsPDF tarafından otomatik eklenecek -->
                </div>
            </div>
        </body>
        </html>
        `;
        
        console.log('📄 HTML dokümant hazırlandı');
        
        // ✅ Geçici container oluştur
        const tempContainer = document.createElement('div');
        tempContainer.innerHTML = fullHtmlDocument;
        tempContainer.style.position = 'absolute';
        tempContainer.style.left = '-9999px';
        tempContainer.style.width = '210mm'; // A4 genişliği
        document.body.appendChild(tempContainer);
        
        console.log('🔄 PDF render başlıyor... (Bu 10-30 saniye sürebilir)');
        
        // ✅ jsPDF oluştur
        const doc = new jsPDF({
            unit: 'mm',
            format: 'a4',
            compress: true
        });
        
        // ✅ jsPDF'nin html() metodunu kullan - METIN BAZLI PDF
        await doc.html(tempContainer, {
            callback: function(pdf) {
                console.log('✅ PDF render tamamlandı!');
                
                // Toplam sayfa sayısı
                const totalPages = pdf.internal.getNumberOfPages();
                console.log(`📊 Toplam sayfa sayısı: ${totalPages}`);
                
                // Her sayfaya sayfa numarası ekle
                for (let i = 1; i <= totalPages; i++) {
                    pdf.setPage(i);
                    pdf.setFontSize(9);
                    pdf.setTextColor(128);
                    pdf.text(
                        `Sayfa ${i} / ${totalPages}`,
                        190, // X pozisyonu (sağ)
                        287, // Y pozisyonu (alt)
                        { align: 'right' }
                    );
                }
                
                console.log('✅ Sayfa numaraları eklendi');
            },
            x: 15, // Sol margin (mm)
            y: 20, // Üst margin (mm)
            width: 180, // İçerik genişliği (mm) - 210mm - 2x15mm
            windowWidth: 794, // A4 genişliği (px) - 210mm x 3.78
            margin: [20, 15, 25, 15], // [Üst, Sağ, Alt, Sol] (mm)
            autoPaging: 'text', // Otomatik sayfalama - metin bazlı
            html2canvas: {
                scale: 0.264583, // mm to px dönüşümü (1mm = 3.78px)
                useCORS: true,
                letterRendering: true,
                logging: false
            }
        });
        
        // ✅ Geçici container'ı temizle
        document.body.removeChild(tempContainer);
        
        console.log('✅ ===== PDF BAŞARIYLA OLUŞTURULDU =====');
        return doc;
        
    } catch (error) {
        console.error('❌ PDF oluşturma hatası:', error);
        throw new Error('Sözleşme PDF dosyası oluşturulurken bir hata oluştu: ' + error.message);
    }
}

// ====================================================================
// KULLANIM:
// kayit.html'de mevcut createPdf fonksiyonunu bu createPdf_NEW ile değiştirin
// ====================================================================




















