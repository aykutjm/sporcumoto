-- Tüm fonksiyonları search_path ile yeniden oluştur
-- Her fonksiyonun farklı parametreleri var (overloading)

-- ============================================
-- 1. check_whatsapp_balance (2 farklı versiyon)
-- ============================================

-- Versiyon 1: p_club_id, p_message_count
DROP FUNCTION IF EXISTS public.check_whatsapp_balance(text, integer);

CREATE OR REPLACE FUNCTION public.check_whatsapp_balance(
    p_club_id text, 
    p_message_count integer DEFAULT 1
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = '' -- 🔒 Güvenlik düzeltmesi
AS $function$
DECLARE
    v_current_balance INTEGER;
    v_has_enough BOOLEAN;
    v_warning BOOLEAN;
BEGIN
    SELECT whatsapp_balance INTO v_current_balance
    FROM public.clubs
    WHERE id = p_club_id;

    IF v_current_balance IS NULL THEN
        RETURN json_build_object(
            'has_enough', false,
            'error', 'Kulüp bulunamadı'
        );
    END IF;

    v_has_enough := v_current_balance >= p_message_count;
    v_warning := v_current_balance <= 100 OR (v_current_balance * 1.0 / GREATEST(p_message_count, 1)) <= 1.1;

    RETURN json_build_object(
        'has_enough', v_has_enough,
        'current_balance', v_current_balance,
        'requested', p_message_count,
        'remaining_after', v_current_balance - p_message_count,
        'low_balance_warning', v_warning
    );
END;
$function$;

-- Versiyon 2: sadece p_club_id (TABLE döner)
-- Bu zaten doğru, değiştirmeye gerek yok

-- ============================================
-- 2. update_whatsapp_balance (3 farklı versiyon)
-- ============================================

-- Versiyon 1: p_club_id, p_amount (4 parametre - jsonb döner)
DROP FUNCTION IF EXISTS public.update_whatsapp_balance(text, integer, text, text);

CREATE OR REPLACE FUNCTION public.update_whatsapp_balance(
    p_club_id text, 
    p_amount integer, 
    p_description text, 
    p_transaction_type text DEFAULT 'debit'::text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = '' -- 🔒 Güvenlik düzeltmesi
AS $function$
DECLARE
    current_balance INTEGER;
    new_balance INTEGER;
    package_record RECORD;
BEGIN
    -- Mevcut bakiyeyi al
    SELECT balance INTO current_balance
    FROM public.whatsapp_packages
    WHERE club_id = p_club_id
    FOR UPDATE;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Kulüp bulunamadı'
        );
    END IF;
    
    -- Yeni bakiyeyi hesapla
    IF p_transaction_type = 'debit' THEN
        new_balance := current_balance - p_amount;
        IF new_balance < 0 THEN
            RETURN jsonb_build_object(
                'success', false,
                'error', 'Yetersiz bakiye'
            );
        END IF;
    ELSE
        new_balance := current_balance + p_amount;
    END IF;
    
    -- Bakiyeyi güncelle
    UPDATE public.whatsapp_packages
    SET 
        balance = new_balance,
        updated_at = NOW()
    WHERE club_id = p_club_id;
    
    -- Transaction kaydı oluştur
    INSERT INTO public.whatsapp_transactions (
        club_id,
        transaction_type,
        amount,
        description,
        balance_before,
        balance_after,
        created_at
    ) VALUES (
        p_club_id,
        p_transaction_type,
        p_amount,
        p_description,
        current_balance,
        new_balance,
        NOW()
    );
    
    RETURN jsonb_build_object(
        'success', true,
        'balance_before', current_balance,
        'balance_after', new_balance
    );
END;
$function$;

-- Versiyon 2: p_club_id, p_amount (6 parametre - json döner)
DROP FUNCTION IF EXISTS public.update_whatsapp_balance(text, integer, character varying, uuid, text, character varying);

CREATE OR REPLACE FUNCTION public.update_whatsapp_balance(
    p_club_id text, 
    p_amount integer, 
    p_action_type character varying, 
    p_package_id uuid DEFAULT NULL::uuid, 
    p_note text DEFAULT NULL::text, 
    p_created_by character varying DEFAULT NULL::character varying
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = '' -- 🔒 Güvenlik düzeltmesi
AS $function$
DECLARE
    v_current_balance INTEGER;
    v_new_balance INTEGER;
    v_log_id UUID;
BEGIN
    -- Mevcut bakiyeyi al
    SELECT whatsapp_balance INTO v_current_balance
    FROM public.clubs
    WHERE id = p_club_id
    FOR UPDATE;

    IF v_current_balance IS NULL THEN
        RAISE EXCEPTION 'Kulüp bulunamadı: %', p_club_id;
    END IF;

    -- Yeni bakiyeyi hesapla
    v_new_balance := v_current_balance + p_amount;

    -- Bakiye negatif olamaz
    IF v_new_balance < 0 THEN
        RAISE EXCEPTION 'Yetersiz bakiye! Mevcut: %, İstenen: %', v_current_balance, ABS(p_amount);
    END IF;

    -- Bakiyeyi güncelle
    UPDATE public.clubs
    SET whatsapp_balance = v_new_balance
    WHERE id = p_club_id;

    -- Log kaydı oluştur
    INSERT INTO public.whatsapp_balance_logs (
        club_id, amount, action_type, previous_balance, new_balance, 
        package_id, note, created_by
    )
    VALUES (
        p_club_id, p_amount, p_action_type, v_current_balance, v_new_balance,
        p_package_id, p_note, p_created_by
    )
    RETURNING id INTO v_log_id;

    RETURN json_build_object(
        'success', true,
        'previous_balance', v_current_balance,
        'new_balance', v_new_balance,
        'amount', p_amount,
        'log_id', v_log_id
    );
END;
$function$;

-- Versiyon 3: p_device_id, p_balance (void döner)
-- Bu zaten doğru, değiştirmeye gerek yok

-- ============================================
-- KONTROL
-- ============================================

SELECT 
    p.proname as "Function",
    pg_get_function_identity_arguments(p.oid) as "Parameters",
    COALESCE(array_to_string(p.proconfig, ', '), 'default') as "Config"
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
    AND p.proname IN ('check_whatsapp_balance', 'update_whatsapp_balance')
ORDER BY p.proname, pg_get_function_identity_arguments(p.oid);
