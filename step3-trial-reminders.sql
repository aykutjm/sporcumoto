-- ADIM 3: check_trial_reminders fonksiyonu

CREATE OR REPLACE FUNCTION public.check_trial_reminders()
RETURNS json AS $$
DECLARE
    settings_record RECORD;
    prereg_record RECORD;
    branch_key text;
    branch_templates jsonb;
    template_config jsonb;
    send_time text;
    current_hour_min text;
    scheduled_datetime timestamp;
    message_text text;
    parent_name text;
    student_name text;
    trial_datetime text;
    success_count int := 0;
    total_count int := 0;
    already_sent boolean;
BEGIN
    current_hour_min := TO_CHAR(NOW(), 'HH24:MI');
    
    FOR settings_record IN
        SELECT * FROM settings WHERE id LIKE 'messageTemplates_%'
    LOOP
        FOR branch_key IN SELECT jsonb_object_keys(settings_record.data::jsonb)
        LOOP
            IF branch_key NOT IN ('updatedAt', 'updatedBy', 'task', 'taskReminder', 'taskMessage') THEN
                branch_templates := settings_record.data::jsonb -> branch_key;
                template_config := branch_templates -> 'trialReminder';
                
                IF (template_config ->> 'enabled')::boolean = true THEN
                    send_time := COALESCE(template_config ->> 'sendTime', '09:00');
                    
                    IF current_hour_min BETWEEN 
                        TO_CHAR((send_time::time - INTERVAL '5 minutes')::time, 'HH24:MI') AND 
                        TO_CHAR((send_time::time + INTERVAL '5 minutes')::time, 'HH24:MI') THEN
                        
                        FOR prereg_record IN
                            SELECT * FROM "preRegistrations"
                            WHERE "clubId" = settings_record."clubId"
                            AND LOWER(branch) = branch_key
                            AND status = 'pending'
                            AND "lessonDate" IS NOT NULL
                            AND DATE("lessonDate") = CURRENT_DATE
                            AND phone IS NOT NULL
                        LOOP
                            total_count := total_count + 1;
                            
                            SELECT EXISTS(
                                SELECT 1 FROM "whatsappMessages"
                                WHERE "toNumber" = prereg_record.phone
                                AND DATE("sentAt") = CURRENT_DATE
                                AND "messageText" LIKE '%deneme%ders%'
                            ) INTO already_sent;
                            
                            IF NOT already_sent THEN
                                parent_name := prereg_record."parentName";
                                student_name := prereg_record."studentName";
                                trial_datetime := TO_CHAR(prereg_record."lessonDate", 'DD.MM.YYYY HH24:MI');
                                
                                message_text := template_config ->> 'text';
                                message_text := REPLACE(message_text, '{VELI_AD_SOYAD}', parent_name);
                                message_text := REPLACE(message_text, '{OGRENCI_AD_SOYAD}', student_name);
                                message_text := REPLACE(message_text, '{DERS_TARIHI}', trial_datetime);
                                
                                scheduled_datetime := CURRENT_DATE + send_time::time;
                                
                                INSERT INTO "messageQueue" (
                                    id,
                                    "clubId",
                                    phone,
                                    message,
                                    "deviceId",
                                    "recipientName",
                                    status,
                                    "scheduledFor",
                                    "createdAt"
                                ) VALUES (
                                    'msg_' || gen_random_uuid()::text,
                                    settings_record."clubId",
                                    prereg_record.phone,
                                    message_text,
                                    prereg_record."deviceId",
                                    parent_name,
                                    'pending',
                                    scheduled_datetime,
                                    NOW()
                                ) ON CONFLICT DO NOTHING;
                                
                                success_count := success_count + 1;
                            END IF;
                        END LOOP;
                    END IF;
                END IF;
            END IF;
        END LOOP;
    END LOOP;
    
    RETURN json_build_object(
        'success', true,
        'type', 'trialReminders',
        'current_time', current_hour_min,
        'total_checked', total_count,
        'queued', success_count,
        'processed_at', NOW()
    );
END;
$$ LANGUAGE plpgsql;
