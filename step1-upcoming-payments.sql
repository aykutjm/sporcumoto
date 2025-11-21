-- ADIM 1: Sadece check_upcoming_payments fonksiyonu

CREATE OR REPLACE FUNCTION public.check_upcoming_payments()
RETURNS json AS $$
DECLARE
    settings_record RECORD;
    member_record RECORD;
    prereg_record RECORD;
    payment_item jsonb;
    branch_key text;
    branch_templates jsonb;
    template_config jsonb;
    days_before int;
    send_time text;
    current_hour_min text;
    scheduled_datetime timestamp;
    reminder_date date;
    message_text text;
    member_name text;
    student_name text;
    payment_date date;
    payment_amount numeric;
    days_left int;
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
                template_config := branch_templates -> 'upcomingPayment';
                
                IF (template_config ->> 'enabled')::boolean = true THEN
                    days_before := COALESCE((template_config ->> 'daysBefore')::int, 2);
                    send_time := COALESCE(template_config ->> 'sendTime', '10:00');
                    
                    IF current_hour_min BETWEEN 
                        TO_CHAR((send_time::time - INTERVAL '5 minutes')::time, 'HH24:MI') AND 
                        TO_CHAR((send_time::time + INTERVAL '5 minutes')::time, 'HH24:MI') THEN
                        
                        FOR member_record IN
                            SELECT * FROM members 
                            WHERE "clubId" = settings_record."clubId"
                            AND LOWER("Brans") = branch_key
                            AND status = 'active'
                            AND "Telefon" IS NOT NULL
                        LOOP
                            SELECT * INTO prereg_record FROM "preRegistrations"
                            WHERE id = member_record."preRegId";
                            
                            IF prereg_record.id IS NOT NULL AND prereg_record."paymentSchedule" IS NOT NULL THEN
                                FOR payment_item IN SELECT * FROM jsonb_array_elements(prereg_record."paymentSchedule"::jsonb)
                                LOOP
                                    payment_date := (payment_item ->> 'dueDate')::date;
                                    reminder_date := payment_date - (days_before || ' days')::interval;
                                    
                                    IF reminder_date::date = CURRENT_DATE AND (payment_item ->> 'paid')::boolean = false THEN
                                        total_count := total_count + 1;
                                        
                                        SELECT EXISTS(
                                            SELECT 1 FROM "whatsappMessages"
                                            WHERE "toNumber" = member_record."Telefon"
                                            AND DATE("sentAt") = CURRENT_DATE
                                            AND "messageText" LIKE '%yaklaşan%ödeme%'
                                        ) INTO already_sent;
                                        
                                        IF NOT already_sent THEN
                                            IF member_record."Resit_Olmayan_Adi_Soyadi" IS NOT NULL THEN
                                                message_text := template_config ->> 'textChild';
                                                member_name := member_record."Ad_Soyad";
                                                student_name := member_record."Resit_Olmayan_Adi_Soyadi";
                                            ELSE
                                                message_text := template_config ->> 'textAdult';
                                                member_name := member_record."Ad_Soyad";
                                                student_name := '';
                                            END IF;
                                            
                                            payment_amount := (payment_item ->> 'amount')::numeric;
                                            days_left := (payment_date - CURRENT_DATE)::int;
                                            
                                            message_text := REPLACE(message_text, '{UYE_AD_SOYAD}', member_name);
                                            message_text := REPLACE(message_text, '{OGRENCI_AD_SOYAD}', student_name);
                                            message_text := REPLACE(message_text, '{TUTAR}', payment_amount::text);
                                            message_text := REPLACE(message_text, '{TARIH}', TO_CHAR(payment_date, 'DD.MM.YYYY'));
                                            message_text := REPLACE(message_text, '{GUN_KALDI}', days_left::text);
                                            
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
                                                member_record."Telefon",
                                                message_text,
                                                member_record."deviceId",
                                                member_name,
                                                'pending',
                                                scheduled_datetime,
                                                NOW()
                                            ) ON CONFLICT DO NOTHING;
                                            
                                            success_count := success_count + 1;
                                        END IF;
                                    END IF;
                                END LOOP;
                            END IF;
                        END LOOP;
                    END IF;
                END IF;
            END IF;
        END LOOP;
    END LOOP;
    
    RETURN json_build_object(
        'success', true,
        'type', 'upcomingPayments',
        'current_time', current_hour_min,
        'total_checked', total_count,
        'queued', success_count,
        'processed_at', NOW()
    );
END;
$$ LANGUAGE plpgsql;
