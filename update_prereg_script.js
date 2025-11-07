// Script to update pre-registration from Elif Beren Karasu to Ahmet Tarık Gümüş
// Run this script in the browser console while logged into the admin panel
// ✅ Supabase & Firebase uyumlu - window.firebase API'si kullanır

async function updatePreRegistration() {
    try {
        console.log('🔍 Searching for pre-registration with phone: 05054771397...');
        
        // Phone number variations to search
        const phoneVariations = [
            '05054771397',
            '5054771397',
            '905054771397'
        ];
        
        // Search for the pre-registration
        let foundPreReg = null;
        
        for (const phoneFormat of phoneVariations) {
            const q = window.firebase.query(
                window.firebase.collection(window.db, 'preRegistrations'),
                window.firebase.where('phone', '==', phoneFormat)
            );
            
            const querySnapshot = await window.firebase.getDocs(q);
            
            if (!querySnapshot.empty) {
                console.log(`✅ Pre-registration found with phone format: ${phoneFormat}`);
                
                // Check all matching documents
                querySnapshot.docs.forEach(doc => {
                    const data = doc.data();
                    console.log('📋 Found pre-registration:', {
                        id: doc.id,
                        parentName: data.parentName,
                        studentName: data.studentName,
                        phone: data.phone,
                        branch: data.branch,
                        status: data.status
                    });
                    
                    // Check if this is the Elif Beren Karasu registration
                    if (data.studentName === 'Elif Beren Karasu' || 
                        data.parentName === 'Elif Beren Karasu') {
                        foundPreReg = { id: doc.id, ...data };
                    }
                });
            }
        }
        
        if (!foundPreReg) {
            console.error('❌ Pre-registration with name "Elif Beren Karasu" not found!');
            console.log('💡 Listing all pre-registrations with this phone number:');
            
            // List all pre-registrations with this phone
            for (const phoneFormat of phoneVariations) {
                const q = window.firebase.query(
                    window.firebase.collection(window.db, 'preRegistrations'),
                    window.firebase.where('phone', '==', phoneFormat)
                );
                
                const querySnapshot = await window.firebase.getDocs(q);
                if (!querySnapshot.empty) {
                    querySnapshot.docs.forEach(doc => {
                        const data = doc.data();
                        console.log({
                            id: doc.id,
                            parentName: data.parentName,
                            studentName: data.studentName,
                            phone: data.phone
                        });
                    });
                }
            }
            
            return;
        }
        
        console.log('✅ Found pre-registration to update:', foundPreReg);
        
        // Determine if it's a child or adult registration
        const isChild = foundPreReg.parentName && foundPreReg.studentName && 
                       foundPreReg.parentName !== foundPreReg.studentName;
        
        // Prepare update data
        const updateData = {};
        
        if (isChild) {
            // If it's a child registration, update studentName
            console.log('👶 This is a child registration, updating studentName...');
            updateData.studentName = 'Ahmet Tarık Gümüş';
        } else {
            // If it's an adult registration, update both
            console.log('👨 This is an adult registration, updating both names...');
            updateData.studentName = 'Ahmet Tarık Gümüş';
            updateData.parentName = 'Ahmet Tarık Gümüş';
        }
        
        // Update the pre-registration in Firebase
        await window.firebase.updateDoc(
            window.firebase.doc(window.db, 'preRegistrations', foundPreReg.id),
            updateData
        );
        
        console.log('✅ Pre-registration updated successfully!');
        console.log('📝 Updated fields:', updateData);
        
        // Also check if there's a member record to update
        const memberQuery = window.firebase.query(
            window.firebase.collection(window.db, 'members'),
            window.firebase.where('preRegistrationId', '==', foundPreReg.id)
        );
        
        const memberSnapshot = await window.firebase.getDocs(memberQuery);
        
        if (!memberSnapshot.empty) {
            const memberDoc = memberSnapshot.docs[0];
            const memberData = memberDoc.data();
            
            console.log('👤 Found associated member record:', {
                id: memberDoc.id,
                Ad_Soyad: memberData.Ad_Soyad,
                Resit_Olmayan_Adi_Soyadi: memberData.Resit_Olmayan_Adi_Soyadi
            });
            
            // Update member record
            const memberUpdateData = {};
            
            if (memberData.Resit_Olmayan_Adi_Soyadi) {
                // Child member - update student name
                memberUpdateData.Resit_Olmayan_Adi_Soyadi = 'Ahmet Tarık Gümüş';
            } else {
                // Adult member - update main name
                memberUpdateData.Ad_Soyad = 'Ahmet Tarık Gümüş';
            }
            
            await window.firebase.updateDoc(
                window.firebase.doc(window.db, 'members', memberDoc.id),
                memberUpdateData
            );
            
            console.log('✅ Member record updated successfully!');
            console.log('📝 Updated fields:', memberUpdateData);
        } else {
            console.log('ℹ️ No associated member record found (member may not have signed contract yet)');
        }
        
        console.log('');
        console.log('🎉 UPDATE COMPLETE!');
        console.log('📌 Old name: Elif Beren Karasu');
        console.log('📌 New name: Ahmet Tarık Gümüş');
        console.log('');
        console.log('💡 Please refresh the admin page to see the changes.');
        
        alert('✅ Güncelleme başarılı! İsim "Elif Beren Karasu" yerine "Ahmet Tarık Gümüş" olarak değiştirildi. Sayfayı yenileyin.');
        
    } catch (error) {
        console.error('❌ Error updating pre-registration:', error);
        alert('❌ Hata: ' + error.message);
    }
}

// Run the update function
console.log('🚀 Starting pre-registration update...');
console.log('📞 Phone: 05054771397');
console.log('👤 Old name: Elif Beren Karasu');
console.log('👤 New name: Ahmet Tarık Gümüş');
console.log('');

updatePreRegistration();

