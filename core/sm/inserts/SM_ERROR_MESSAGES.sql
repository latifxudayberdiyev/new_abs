SET LINESIZE 250
SET PAGESIZE 200
SET SERVEROUTPUT ON
WHENEVER SQLERROR CONTINUE

DECLARE
  v_Code number; v_Msg varchar2(4000);
  PROCEDURE mk(p_code varchar2, p_desc varchar2, p_params number, p1 varchar2, p2 varchar2, p3 varchar2, p4 varchar2) IS
  BEGIN
    Mle_Kernel.Save_Template_With_Error(
      i_Message_Code => p_code, i_Description => p_desc, i_Param_Count => p_params,
      i_Format_String => Mlt_Const.c_Default_Format_String,
      i_Message_Mask_Lang1 => p1, i_Message_Mask_Lang2 => p2, i_Message_Mask_Lang3 => p3, i_Message_Mask_Lang4 => p4,
      i_Message_Mask_Lang5 => null, i_Message_Mask_Lang6 => null, i_Message_Mask_Lang7 => null,
      i_Message_Mask_Lang8 => null, i_Message_Mask_Lang9 => null, i_Message_Mask_Lang10 => null,
      i_Module_Code => 'SM', i_Error_Code => null, o_Code => v_Code, o_Msg => v_Msg);
    Dbms_Output.Put_Line(p_code || ' -> ' || v_Code || ' ' || v_Msg);
  END;
BEGIN
  mk('SM_SYSTEM_ERROR', 'SM: generic system error fallback', 0,
     'Системная ошибка.', 'Тизим хатолиги.', 'Tizim xatoligi.', 'System error.');

  mk('SM_PARAM_REQUIRED', 'SM_CONTROL.Check_Process_Params: required param missing', 1,
     'Не указан обязательный параметр для выполнения процесса. key:$1',
     'Жараённи бажариш учун мажбурий параметр кўрсатилмаган. key:$1',
     'Jarayonni bajarish uchun majburiy parametr ko''rsatilmagan. key:$1',
     'Required parameter for process execution is not specified. key:$1');

  mk('SM_PARAM_NOT_NUMBER', 'SM_CONTROL.Check_Process_Params: value must be number', 1,
     'Введено некорректное значение. Пожалуйста, убедитесь, что вводятся только цифры. key:$1',
     'Нотўғри қиймат киритилди. Илтимос, фақат рақам киритилганига ишонч ҳосил қилинг. key:$1',
     'Noto''g''ri qiymat kiritildi. Iltimos, faqat raqam kiritilganiga ishonch hosil qiling. key:$1',
     'Invalid value entered. Please make sure only digits are entered. key:$1');

  mk('SM_PARAM_NOT_DATE', 'SM_CONTROL.Check_Process_Params: value must be date', 1,
     'Введено некорректное значение. Пожалуйста, убедитесь, что вводится только дата. key:$1',
     'Нотўғри қиймат киритилди. Илтимос, фақат сана киритилганига ишонч ҳосил қилинг. key:$1',
     'Noto''g''ri qiymat kiritildi. Iltimos, faqat sana kiritilganiga ishonch hosil qiling. key:$1',
     'Invalid value entered. Please make sure only a date is entered. key:$1');

  mk('SM_PARAM_OUT_OF_RANGE', 'SM_CONTROL.Check_Process_Params: value length out of range', 3,
     'Указанное значение выходит за допустимый диапазон. Минимум: $1, Максимум: $2, Введено: $3',
     'Киритилган қиймат рухсат этилган диапазондан ташқарида. Мин: $1, Макс: $2, Киритилди: $3',
     'Kiritilgan qiymat ruxsat etilgan diapazondan tashqarida. Min: $1, Maks: $2, Kiritildi: $3',
     'The provided value is out of the allowed range. Min: $1, Max: $2, Provided: $3');

  mk('SM_OBJECT_REJECTED', 'SM_CONTROL.Check_Object_Action_Control: object was rejected', 0,
     'Невозможно продолжить процесс, так как данный объект был отклонён.',
     'Жараённи давом эттириб бўлмайди, чунки ушбу объект рад этилган.',
     'Jarayonni davom ettirib bo''lmaydi, chunki ushbu obyekt rad etilgan.',
     'Cannot continue the process because this object has been rejected.');

  mk('SM_ACTION_ID_REQUIRED', 'SM_CONTROL.Check_Object_Action_Control: action_id not specified', 0,
     'Вы не указали "action_id".',
     'Сиз "action_id"ни кўрсатмадингиз.',
     'Siz "action_id"ni ko''rsatmadingiz.',
     'You did not specify "action_id".');

  mk('SM_PROCESS_NOT_FOUND', 'SM_INIT.Reinit_Process_Data: process not found by id', 0,
     'Не удалось найти процесс с указанным идентификатором',
     'Кўрсатилган идентификатор бўйича жараён топилмади',
     'Ko''rsatilgan identifikator bo''yicha jarayon topilmadi',
     'Process with the specified identifier was not found');

  mk('SM_LOCK_BUSY', 'SM_KERNEL.Lock_Process: process already locked', 0,
     'Запустить не удалось. Обработка транзакций запущена автоматически или другим пользователем',
     'Ишга тушириб бўлмади. Транзакцияларни қайта ишлаш автоматик равишда ёки бошқа фойдаланувчи томонидан ишга туширилган',
     'Ishga tushirib bo''lmadi. Tranzaksiyalarni qayta ishlash avtomatik ravishda yoki boshqa foydalanuvchi tomonidan ishga tushirilgan',
     'Failed to start. Transaction processing was started automatically or by another user');

  mk('SM_TRANSITION_NOT_FOUND', 'SM_KERNEL.Check_Tranzition: transition not found', 0,
     'Не удалось найти переход для данного состояния',
     'Ушбу ҳолат учун ўтиш топилмади',
     'Ushbu holat uchun o''tish topilmadi',
     'Transition for this state was not found');

  mk('SM_INVALID_OBJECT_STATE', 'SM_KERNEL.Check_Tranzition_State: invalid current state', 1,
     'Состояние объекта должно быть равно одному из: $1',
     'Объект ҳолати қуйидагилардан бирига тенг бўлиши керак: $1',
     'Obyekt holati quyidagilardan biriga teng bo''lishi kerak: $1',
     'Object state must be one of: $1');

  mk('SM_PARENT_OBJECT_NOT_FOUND', 'SM_KERNEL.Get_Par_Object_Id: parent object not found', 0,
     'Родительский объект не найден.',
     'Она объект топилмади.',
     'Ona obyekt topilmadi.',
     'Parent object not found.');

  mk('SM_NO_PROCEDURE_ON_EVENT', 'SM_KERNEL.Run_Event_Procedures: no procedure bound to event', 1,
     'На событии не была выполнена ни одна процедура. process_code:$1',
     'Ушбу event учун бирорта процедура бажарилмади. process_code:$1',
     'Ushbu event uchun birorta protsedura bajarilmadi. process_code:$1',
     'No procedure was executed for this event. process_code:$1');

  mk('SM_PROCEDURE_NAME_NOT_BOUND', 'SM_KERNEL.Run_Event_Procedures: procedure name not bound', 1,
     'Имя процедуры не привязано (не указано). procedure_code:$1',
     'Процедура номи боғланмаган (кўрсатилмаган). procedure_code:$1',
     'Protsedura nomi bog''lanmagan (ko''rsatilmagan). procedure_code:$1',
     'Procedure name is not bound (not specified). procedure_code:$1');

  mk('SM_EVENT_NOT_FOUND', 'SM_KERNEL.Run_Process_Event: event not found', 1,
     'Событие не найдено. process_code:$1',
     'Event топилмади. process_code:$1',
     'Event topilmadi. process_code:$1',
     'Event not found. process_code:$1');

  mk('SM_OBJECT_NOT_FOUND_BY_RELATION', 'SM_KERNEL.Set_Process_Get: object not found by relation_id', 2,
     'По заданному relation_id объект не обнаружен $1:$2',
     'Кўрсатилган relation_id бўйича объект топилмади $1:$2',
     'Ko''rsatilgan relation_id bo''yicha obyekt topilmadi $1:$2',
     'Object not found for the given relation_id $1:$2');

  mk('SM_PARENT_DATA_INCONSISTENT', 'SM_KERNEL.Set_Object: parent data inconsistent', 0,
     'Данные родительского объекта недействительны или неконсистентны.',
     'Она объект маълумотлари ярокли эмас ёки мос эмас.',
     'Ona obyekt ma''lumotlari yaroqli emas yoki mos emas.',
     'Parent object data is invalid or inconsistent.');

  mk('SM_OBJECT_NOT_FOUND', 'SM_KERNEL.Set_Object: specified object not found', 2,
     'Указанный объект не найден. $1:$2',
     'Кўрсатилган объект топилмади. $1:$2',
     'Ko''rsatilgan obyekt topilmadi. $1:$2',
     'Specified object not found. $1:$2');

  mk('SM_CREATE_OPERATION_REQUIRED', 'SM_KERNEL.Set_Object: create operation required first', 0,
     'Пожалуйста, сначала выполните операцию создания.',
     'Илтимос, аввал яратиш амалини бажаринг.',
     'Iltimos, avval yaratish amalini bajaring.',
     'Please perform the create operation first.');

  mk('SM_PROCESS_ALREADY_COMPLETED', 'SM_KERNEL.Rerun_Process: process already completed', 0,
     'Процесс уже завершён и не может быть запущен повторно',
     'Жараён аллақачон якунланган ва қайта ишга туширилиши мумкин эмас',
     'Jarayon allaqachon yakunlangan va qayta ishga tushirilishi mumkin emas',
     'The process has already been completed and cannot be restarted');

  mk('SM_PROCESS_CODE_NOT_FOUND', 'SM_KERNEL.Set_Method: process_code not found in request', 1,
     'Код процесса не найден. process_code:$1',
     'Жараён коди топилмади. process_code:$1',
     'Jarayon kodi topilmadi. process_code:$1',
     'Process code not found. process_code:$1');

  COMMIT;
END;
/
PROMPT === verify count ===
SELECT COUNT(*) FROM MLT_ERROR_CODES WHERE MODULE_CODE='SM';
EXIT;
