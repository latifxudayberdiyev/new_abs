----------------------------------------------------------------------------------------------------
-- purge_core_process_access_log.sql
--
-- CORE_PROCESS_ACCESS_LOG (Core_Api process-code guard, log-then-enforce LOG-bosqichi)
-- jadvali uchun davriy tozalash (purge) skripti.
--
-- Nega kerak: Core_Api.Check_Process_Access / Write_Access_Log (ilgari Log_Process_Access
-- nomi ostida bitta protsedura edi, shu sessiyada ikkiga ajratildi) har bir
-- Execute_Process_Clob / Get_Model_Clob chaqiruvida (avtonom tranzaksiya bilan) bittadan
-- qator INSERT qiladi - hech qanday
-- tabiiy chegara/limit yo'q. Jadvalning o'zi CORE_DATA tablespace'da (production biznes
-- jadvallari bilan BIRGA) va o'z ustidagi hujjatda "vaqtinchalik" deb yozilgan bo'lsa ham,
-- bu holat kod tomonidan hech narsa bilan ta'minlanmagan edi - shu sabab bu skript.
--
-- Retention oynasi: 30 kun (event_on < sysdate - 30). 30 kun tanlangan, chunki bu
-- log-then-enforce ko'chirishning 1-bosqichi (LOG) uchun ENFORCE'ga o'tish qarorini
-- qabul qilishga YETARLI tarixni saqlaydi (odatiy oylik trafik siklini qamrab oladi),
-- shu bilan birga jadval hajmini cheklab turadi.
--
-- DIQQAT (faqat ALLOW qatorlari purge qilinadi): bu skript FAQAT enforce_action='ALLOW'
-- bo'lgan (odatiy, hech narsa bloklanmagan/ogohlantirilmagan) qatorlarni retention oynasidan
-- eski bo'lsa o'chiradi. enforce_action in ('BLOCK','WARN_BYPASS') (rad etilgan chaqiruvlar
-- va DEBUG-bypass bilan bajarilgan privileged chaqiruvlar) HAMDA outcome='FOREIGN_PROCESS_ID'
-- (F2 - boshqa foydalanuvchining process_id'i bilan rerun urinishi) qatorlari BU SKRIPT
-- TOMONIDAN HECH QACHON o'chirilmaydi - ular oddiy ALLOW-trafik shovqinidan farqli, rad
-- etilgan kirish va privileged-bypass uchun KOMPENSATSION AUDIT IZI (compensating control)
-- bo'lib, ALLOW qatorlariga qaraganda UZOQROQ saqlash muddatini talab qiladi (incident
-- response/forensika/muvofiqlik uchun). Bu qatorlarni tozalash kerak bo'lsa - alohida,
-- uzoqroq retention oynali va lead/reviewer tasdig'i bilan bajariladigan alohida jarayon
-- (out of scope bu skript uchun).
--
-- Bajarilish usuli: bitta katta DELETE o'rniga BOUNDED BATCH tsikl (har safar ROWNUM <= 10000,
-- oralig'ida COMMIT) - jonli tizimda bitta ulkan tranzaksiya (katta UNDO, uzoq lock) hosil
-- qilmaslik uchun.
--
-- Rejalashtirish: bu skript o'zi HECH QANDAY DBMS_SCHEDULER job'ini yaratmaydi/o'zgartirmaydi -
-- bu repo doirasida (CORE_PROCESS_ACCESS_LOG kontekstida) shunday job hali yo'q, shuning uchun
-- yangi scheduler-freymvork o'ylab topilmaydi. Bu skriptni davriy ishga tushirish (masalan
-- kunlik/haftalik) - operatsion (DBA) vazifa: qo'lda yoki mavjud tashqi cron/job vositasi orqali
-- rejalashtiring. (Eslatma: repo'da AUTH moduli uchun DBMS_SCHEDULER namunasi mavjud -
-- auth/scheduler_purge_expired.sql - agar kelajakda shu jadval uchun ham shunga o'xshash job
-- kerak bo'lsa, o'sha namunaga qarang; bu skript o'zi uni yaratmaydi.)
--
-- Idempotent: skript necha marta ishga tushirilsa ham xavfsiz - shunchaki retention oynasidan
-- eski qatorlar (agar bo'lsa) o'chiriladi, aks holda 0 qator o'chiriladi.
--
-- Run as CORE schema owner: sqlplus core/*** @access/packages/purge_core_process_access_log.sql
----------------------------------------------------------------------------------------------------
set serveroutput on size unlimited;

declare
  c_Retention_Days constant number := 30;
  c_Batch_Size     constant number := 10000;
  v_Deleted_Total  number := 0;
  v_Deleted_Batch  number;
begin
  Dbms_Output.Put_Line('CORE_PROCESS_ACCESS_LOG purge boshlandi - retention = ' ||
                        c_Retention_Days || ' kun (event_on < sysdate - ' || c_Retention_Days ||
                        '), FAQAT enforce_action=''ALLOW'' qatorlari (BLOCK/WARN_BYPASS - ' ||
                        'kompensatsion audit izi - saqlanadi).');
  loop
    delete from CORE_PROCESS_ACCESS_LOG
     where event_on < sysdate - c_Retention_Days
       and enforce_action = 'ALLOW'
       -- LOG rejimida (joriy holat) FOREIGN_PROCESS_ID (F2) qatorlari ham enforce_action='ALLOW'
       -- oladi (LOG rejimida HECH narsa haqiqatan bloklanmaydi) - shunga qaramay bu outcome
       -- kompensatsion audit izi hisoblanadi (yuqoridagi sarlavha izohiga qarang), shu sabab
       -- enforce_action=ALLOW bo'lsa ham ATAYLAB bu yerda alohida chiqarib tashlanadi.
       and outcome != 'FOREIGN_PROCESS_ID'
       and rownum <= c_Batch_Size;
    v_Deleted_Batch := sql%rowcount;
    v_Deleted_Total := v_Deleted_Total + v_Deleted_Batch;
    commit;
    Dbms_Output.Put_Line('  ... ' || v_Deleted_Batch || ' ta qator o''chirildi (jami: ' ||
                          v_Deleted_Total || ').');
    exit when v_Deleted_Batch < c_Batch_Size;
  end loop;
  Dbms_Output.Put_Line('CORE_PROCESS_ACCESS_LOG purge tugadi - jami o''chirilgan qatorlar: ' ||
                        v_Deleted_Total || '.');
end;
/
