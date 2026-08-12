CREATE OR REPLACE TYPE "JSON_STRING_T"                                          force as Object (
--
-- Author   : Шаюсупов Ш.А.
-- Version  : ->>27112020<<-
-- Created  : 22.09.2019 06:14:18
-- System   : ИАБС 6.5.0
-- Subsystem: Ядро ИАБС 6.5.0
-- Purpose  : Объектный тип для возможности поддержки в PL/SQL длинных JSON-строк
--            Позволяет создать, хранить и обработать в памяти длинных строк в формате JSON
--            Позволяет сжатие больших строк при хранении в памяти, что позволяет многократно
--            уменьшить потребляемую память


  -- Приватные реквизиты строки (заключены в кавычки, чтобы усложнять
  -- использование извне)
  "Length "       Integer(12),      -- Общая длина строки
  "Level "        Integer(5),       -- Уровень глубины текущего блока данных (не более 32767)
  "Levels "       Varchar2(32767),  -- Типы блоков данных вложенных уровней (O-Объект, L-Список)
  "Is_Empty "     Varchar2(1),      -- Текущий уровень еще пуст
  "Compress "     Varchar2(1),      -- Сжатие строки для экономии памяти
  "Max_Length "   Integer(12),      -- Допустимая длина строки
  "Buf "          Varchar2(32767),  -- Основной буфер для хранения JSON-строки
  "Raw_Data "     Array_Raw,        -- Постранично-организованный буфер для хранения большой строки
  --
  -- Соглашения о параметрах форматирования
  "Def_CharSet "  Varchar2(15),     -- Кодировка символов по умолчанию
  "Fmt_Number "   Varchar2(43),     -- Формат значений числового типа
  "Fmt_Date "     Varchar2(10),     -- Формат значений типа дата
  "Fmt_Time "     Varchar2(21),     -- Формат значений типа дата и время
  --
  -- Соглашения о значениях по умолчению
  "Null_Number "  Varchar2(4),      -- Строка для замены числового значения NULL
  "Null_Boolean " Varchar2(5),      -- Строка для замены логического значения NULL
  "Null_Date "    Varchar2(12),     -- Строка для замены NULL-значения типа дата и время



  -- Статический метод для получения версии тела объектного типа
  -- Потомственые типы должны определять собственные методы для
  -- получения версии
  static function GetVersion return Varchar2,


  -- Конструктор для создания нового пустого экземпляра типа
  Constructor Function JSON_String_T (
    Self in out nocopy JSON_String_T
  )
  Return Self as Result,

  -- Инициализировать атрибуты новой строки
  final member procedure Init (Self in out nocopy JSON_String_T),

  -- Инициализировать соглашения по форматированию данных
  final member procedure Set_Formats (
    Self in out nocopy JSON_String_T,
    i_Def_CharSet  Varchar2 := NULL,     -- Кодировка символов по умолчанию
    i_Fmt_Number   Varchar2 := NULL,     -- Формат значений числового типа
    i_Fmt_Date     Varchar2 := NULL,     -- Формат значений типа дата
    i_Fmt_Time     Varchar2 := NULL      -- Формат значений типа дата и время
  ),

  -- Инициализировать соглашения о значениях по умолчению
  final member procedure Set_Defaults (
    Self in out nocopy JSON_String_T,
    i_Null_Number  Varchar2 := NULL,     -- Значение для замены NULL-числа
    i_Null_Boolean Varchar2 := NULL,     -- Значение для замены NULL-Boolean
    i_Null_Date    Varchar2 := NULL      -- Значение для замены NULL-даты
  ),

  -- Задать признак сжатии строки при переносе на расширенный буфер
  -- Установка данного значения в "Y" (по умолчанию) позволяет экономить
  -- оперативную память при незначительном снижении производительности
  final member procedure Set_Compress (
    Self in out nocopy JSON_String_T,
    i_Compress  Varchar2 := 'Y'
  ),

  -- Установить новый предел для размера буфера
  -- Добавлен от 27.11.2020
  final member procedure Set_Max_Size (
    Self in out nocopy JSON_String_T,
    i_New_Size  Number                -- Новый предел для размера буфера
  ),

  -- Вызвать NULL-оператор
  -- Ничего не делает. Может вызываться для того, чтобы сделать компилятор довольным
  final member procedure Op_NULL (Self in JSON_String_T),

  -- Генерировать исключение с заданным  кодом ошибки и сообщением об ошибке
  final member procedure Error (
    Self          in JSON_String_T,
    i_Error_Code  in PLS_Integer := 0,
    i_Error_Msg   in Varchar2
  ),

  -- Возвращать длину строки
  final member function Get_Length Return Integer,

  -- Возвращать уровень вложенности текущего блока
  final member function Get_Level Return Integer,

  -- Возвращать количество внутренних буферов для хранения строки,
  -- включая основной и расширенные буфера
  final member function Get_Buf_Count Return Integer,

  -- Клонировать текущую длинную строку
  final member function Cast_To_Raw (i_Str Varchar2) Return Raw,

  -- Клонировать текущую длинную строку
  final member function Cast_To_String (i_Raw Raw) Return Varchar2,

  -- Преобразовать заданную строку в JSON-совместимый формат
  -- Преобразует специальные символы в Escape-последовательности
  final static function Cast_To_JSON (i_Str Varchar2) return Varchar2,

  -- Упаковать строку в бинарном представлении
  final member function Compress_Raw (i_Raw Raw) Return Raw,

  -- Упаковать строку в символьном представлении
  final member function Compress_Str (i_Str Varchar2) Return Raw,

  -- Распаковать сжатую строку и возвращать результат в бинарном представлении
  final member function Uncompress_To_Raw (i_Raw Raw) Return Raw,

  -- Распаковать сжатую строку и возвращать результат в символьном представлении
  final member function Uncompress_To_Str (i_Raw Raw) Return Varchar2,


  -- Преобразовать значение символьного типа в формат JSON
  -- Вставит двойные кавычки на начало и конец строки
  -- Существующие в строке кавычки и специальные символы превращает в JSON-совместимые символы
  final member function Format (i_Str Varchar2) Return Varchar2,

  -- Преобразовать значение числового типа в формат JSON
  final member function Format (i_Value Number, i_Fmt Varchar2 := NULL) Return Varchar2,

  -- Преобразовать значение типа дата и время в формат JSON
  final member function Format (i_Value Date, i_Fmt Varchar2 := NULL) Return Varchar2,

  -- Преобразовать значение типа дата и время в формат JSON
  final member function Format (i_Value Boolean) Return Varchar2,


  -- Формировать пару ключ-значение для вставки в формате JSON
  -- При необходимостии вставить лидирующий запятой
  -- Только для внутреннего назначения
  final member function "_Make_Comma_Name " (i_Name Varchar2) Return Varchar2,

  -- Возвращать содержимое страницы буфера с заданным индексом в двоичном представлении
  -- Только для внутреннего назначения
  final member function "_Extract_Raw_Data " (
    i_Index      Integer,
    i_Compress   Varchar2 := 'Y',
    i_Debugging  Boolean  := False
  )
  Return Raw,

  -- Возвращать содержимое страницы буфера с заданным индексом в виде строки
  -- Только для внутреннего назначения
  final member function "_Extract_String " (
    i_Index      Integer,
    i_Debugging  Boolean  := False
  )
  Return Varchar2,

  --
  -- Только для внутреннего назначения
  final member procedure "_Flash_Buf " (Self in out nocopy JSON_String_T),

  --
  -- Только для внутреннего назначения
  final member procedure "_Append_Str " (
    Self in out nocopy JSON_String_T,
    i_Str  Varchar2
  ),

  -- Вставить объект JSON в текущий объект JSON в качестве значения ключа
  -- Только для внутреннего назначения
  final member procedure "_Append_JSON " (
    Self in out nocopy JSON_String_T,
    i_Key    Varchar2,
    i_Value  JSON_String_T
  ),

  -- Открыть новый блок данных JSON
  -- Только для внутреннего назначения
  final member procedure "_Open_New_Level " (
    Self in out nocopy JSON_String_T,
    i_Open_Char  Varchar2,
    i_Type_Char  Varchar2,
    i_Name       Varchar2 := NULL
  ),

  -- Закрыть текущий блок данных JSON
  -- Только для внутреннего назначения
  final member procedure "_Close_Cur_Level " (
    Self in out nocopy JSON_String_T,
    i_Close_Char  Varchar2,
    i_Type_Char   Varchar2
  ),

  -- Добавить подготовленное значение в список
  -- Только для внутреннего назначения
  final member procedure "_Put_In_List " (
    Self in out nocopy JSON_String_T,
    i_Quoted_Value  Varchar2
  ),

  -- Добавить подготовленную пару ключ-значение в объект JSON
  -- Только для внутреннего назначения
  final member procedure "_Put_In_Object " (
    Self in out nocopy JSON_String_T,
    i_Quoted_Key    Varchar2,
    i_Quoted_Value  Varchar2
  ),

  -- Добавить длинную строку в объект или список
  -- Только для внутреннего назначения
  final member procedure "_Put_Long_String " (
    Self in out nocopy JSON_String_T,
    i_Level  Varchar2,
    i_Key    Varchar2,
    i_Value  Array_Varchar2
  ),

  -- Вставить тело готового объекта JSON или списка JSON
  -- Тело объекта/списка вставляется без проверки на корректность
  -- Только для внутреннего назначения
  final member procedure "_Put_Object_Body " (
    Self in out nocopy JSON_String_T,
    i_Key        Varchar2,
    i_Obj_Body   Array_Varchar2,
    i_Level_Type Varchar2
  ),

  -- Процедура пакетной вставки списка значений в буфер
  -- В параметре i_Types можно передавать типы значений элементов коллекции
  -- Если коллекция содержит больше элементов, чем длина параметра i_Types, то для
  -- оставшихся элементов тип будет как "s" (строка, пустые строки вставляются как
  -- "null"). Неверные значения типов значений также заменяются на "s".
  -- ВНИМАНИЕ! В данной процедуре корректность числовых значений не проверяется!
  -- Параметры:
  --    i_Values - Коллекция значений списка
  --    i_Types  - Коллекция типов значений списка, где:
  --               S - строка, пустые строки вставляются как пустая строка ("")
  --               s - строка, пустые строки вставляются как нуль ("null")
  --               N - число, NULL-значения вставляются как пустая строка ("")
  --               n - число, NULL-значения вставляются как нуль ("null")
  --               B - логическое значение (true, false),
  --                   NULL-значения вставляются как пустая строка (""),
  --                   некорректные значения вставляются как ("false")
  --               b - логическое значение,
  --                   NULL-значения вставляются как нуль ("null"),
  --                   некорректные значения вставляются как строка
  --               Z - Вставить "null", соответствующее значение в коллекции игнорируется
  --               z - Вставить "null", если соответствующее значение в коллекции
  --                   не является "null" или NULL, то вставляется как строка
  --    i_Index  - Индекс элемента коллекции, с которой должна начинаться вставка
  --    i_Count  - Количество элементов для вставки (NULL - все элементы, начиная
  --               с позиции i_Index)
  -- Только для внутреннего назначения
  final member procedure "_Put_Array " (
    Self in out nocopy JSON_String_T,
    i_Key     Varchar2,
    i_Values  Array_Varchar2,
    i_Types   Varchar2,
    i_Index   Simple_Integer := 1,
    i_Count   PLS_Integer    := NULL
  ),

  -- Удостовериться, что заданная коллекция строк содержит синтаксически корректное
  -- описание (тело) объекта или списка JSON
  final member Procedure "_Check_Syntax " (
    Self in JSON_String_T,
    i_JSON  Array_Varchar2,
    i_Type  Varchar2
  ),


  -- Проверить, закрыть ли JSON-строка
  -- Запрещается добавление новых элементов в закрытую строку
  final member function Is_Closed Return Boolean,

  -- Проверить, открыть ли JSON-строка для добавления новых элементов
  final member function Is_Open Return Boolean,

  -- Удостовериться, JSON-строка закрыта
  -- Запрещается извлечение содержимого буфера при не закрытой строке
  -- Из-за критичности на скорость допускается дублирование кода других методов
  final member procedure Check_Closed (Self in JSON_String_T),

  -- Удостовериться, JSON-строка открыта для добавления новых элементов
  -- Запрещается добавление новых элементов в закрытую строку
  -- Из-за критичности на скорость допускается дублирование кода других методов
  final member procedure Check_Open (Self in JSON_String_T),

  -- Удостовериться, что заданный тип блока данных соответствует заданному типу блока
  -- Из-за критичности на скорость допускается дублирование кода других методов
  final member procedure Check_Level (
    Self in JSON_String_T,
    i_Level_Type  Varchar2,
    i_Op_Type     Varchar2
  ),

  -- Удостовериться, что заданная строка содержит синтаксически корректное
  -- описание объекта JSON
  final member Procedure Check_Syntax_Object (
    Self in JSON_String_T,
    i_JSON  Varchar2
  ),

  -- Удостовериться, что заданная коллекция строк содержит синтаксически корректное
  -- описание объекта JSON
  final member Procedure Check_Syntax_Object (
    Self in JSON_String_T,
    i_JSON  Array_Varchar2
  ),

  -- Удостовериться, что заданная строка содержит синтаксически корректное
  -- описание списка (массива) JSON
  final member Procedure Check_Syntax_Array (
    Self in JSON_String_T,
    i_JSON  Varchar2
  ),

  -- Удостовериться, что заданная коллекция строк содержит синтаксически корректное
  -- описание списка (массива) JSON
  final member Procedure Check_Syntax_Array (
    Self in JSON_String_T,
    i_JSON  Array_Varchar2
  ),

  -- Закрыть JSON-строку
  -- В отличие от метода Close_JSON, который закрывает текущий JSON-объект,
  -- попытается закрыть основной блок JSON-строки
  -- При обнаружении незакрытого вложенного блока любого типа генерирует исключение
  final member procedure Close (Self in out nocopy JSON_String_T),

  -- Открыть ранее закрытыю JSON-строку для изменений
  -- Если JSON-строка не закрыто, то генерирует исключение
  final member procedure Open (Self in out nocopy JSON_String_T),

  -- Открыть новый объект JSON с заданным именем
  final member procedure Open_JSON (
    Self in out nocopy JSON_String_T,
    i_Name  Varchar2 := NULL
  ),

  -- Закрыть текущий объект JSON
  final member procedure Close_JSON (Self in out nocopy JSON_String_T),

  -- Открыть новый список значений с заданным именем
  final member procedure Open_Array (
    Self in out nocopy JSON_String_T,
    i_Name  Varchar2 := NULL
  ),

  -- Закрыть текущий объект JSON
  final member procedure Close_Array (Self in out nocopy JSON_String_T),

  -- Добавть пару ключ-значение стротного типа в текущий объект JSON
  final member procedure Put (
    Self in out nocopy JSON_String_T,
    i_Key    Varchar2,
    i_Value  Varchar2
  ),

  -- Добавть пару ключ-значение числового типа в текущий объект JSON
  final member procedure Put (
    Self in out nocopy JSON_String_T,
    i_Key    Varchar2,
    i_Value  Number,
    i_Fmt    Varchar2 := NULL
  ),

  -- Добавть пару ключ-значение типа дата и время в текущий объект JSON
  final member procedure Put (
    Self in out nocopy JSON_String_T,
    i_Key    Varchar2,
    i_Value  Date,
    i_Fmt    Varchar2 := NULL
  ),

  -- Добавть пару ключ-значение логического типа в текущий объект JSON
  final member procedure Put (
    Self in out nocopy JSON_String_T,
    i_Key    Varchar2,
    i_Value  Boolean
  ),

  -- Вставить длинную строку в текущий объект JSON в качестве значения ключа
  final member procedure Put (
    Self in out nocopy JSON_String_T,
    i_Key    Varchar2,
    i_Value  Long_String
  ),

  -- Вставить объект JSON в текущий объект JSON в качестве значения ключа
  final member procedure Put (
    Self in out nocopy JSON_String_T,
    i_Key    Varchar2,
    i_Value  JSON_String_T
  ),

  -- Вставить коллекцию строк в текущий объект JSON в качестве списка-значения ключа
  -- В параметре i_Types можно передавать типы значений элементов коллекции
  -- Если коллекция содержит больше элементов, чем длина параметра i_Types, то для
  -- оставшихся элементов тип будет как "s" (строка, пустые строки вставляются как
  -- "null"). Неверные значения типов значений также заменяются на "s".
  -- ВНИМАНИЕ! В данной процедуре корректность числовых значений не проверяется!
  -- Параметры:
  --    i_Values - Коллекция значений списка
  --    i_Types  - Коллекция типов значений списка, где:
  --               S - строка, пустые строки вставляются как пустая строка ("")
  --               s - строка, пустые строки вставляются как нуль ("null")
  --               N - число, NULL-значения вставляются как пустая строка ("")
  --               n - число, NULL-значения вставляются как нуль ("null")
  --               B - логическое значение (true, false),
  --                   NULL-значения вставляются как пустая строка (""),
  --                   некорректные значения вставляются как ("false")
  --               b - логическое значение,
  --                   NULL-значения вставляются как нуль ("null"),
  --                   некорректные значения вставляются как строка
  --               Z - Вставить "null", соответствующее значение в коллекции игнорируется
  --               z - Вставить "null", если соответствующее значение в коллекции
  --                   не является "null" или NULL, то вставляется как строка
  --    i_Index  - Индекс элемента коллекции, с которой должна начинаться вставка
  --    i_Count  - Количество элементов для вставки (NULL - все элементы, начиная
  --               с позиции i_Index)
  final member procedure Put (
    Self in out nocopy JSON_String_T,
    i_Key     Varchar2,
    i_Values  Array_Varchar2,
    i_Types   Varchar2       := NULL,
    i_Index   Simple_Integer := 1,
    i_Count   PLS_Integer    := NULL
  ),

  -- Добавть значение нуль по ключу в текущий объект JSON
  final member procedure Put_Null (
    Self in out nocopy JSON_String_T,
    i_Key  Varchar2
  ),

  -- Вставить коллекцию строк в текущий объект JSON в качестве единой строки
  final member procedure Put_As_String (
    Self in out nocopy JSON_String_T,
    i_Key    Varchar2,
    i_Value  Array_Varchar2
  ),

  -- Вставить объект JSON в текущий объект JSON в качестве значения ключа
  final member procedure Put_As_Array (
    Self in out nocopy JSON_String_T,
    i_Key    Varchar2,
    i_Value  Varchar2,
    i_Check  Boolean := True
  ),

  -- Вставить тело списка JSON в текущий объект JSON в качестве значения ключа
  final member procedure Put_As_Array (
    Self in out nocopy JSON_String_T,
    i_Key    Varchar2,
    i_Value  Array_Varchar2,
    i_Check  Boolean       := True
  ),

  -- Вставить объект JSON в текущий объект JSON в качестве значения ключа
  final member procedure Put_As_JSON (
    Self in out nocopy JSON_String_T,
    i_Key    Varchar2,
    i_Value  Varchar2,
    i_Check  Boolean := True
  ),

  -- Вставить объект JSON в текущий объект JSON в качестве значения ключа
  final member procedure Put_As_JSON (
    Self in out nocopy JSON_String_T,
    i_Key    Varchar2,
    i_Value  Array_Varchar2,
    i_Check  Boolean       := True
  ),


  -- Добавть символьное значение в текущий список
  final member procedure Add_Elem (
    Self in out nocopy JSON_String_T,
    i_Value  Varchar2
  ),

  -- Добавть числовое значение в текущий список
  final member procedure Add_Elem (
    Self in out nocopy JSON_String_T,
    i_Value  Number,
    i_Fmt    Varchar2 := NULL
  ),

  -- Добавть значение типа дата и время в текущий список
  final member procedure Add_Elem (
    Self in out nocopy JSON_String_T,
    i_Value  Date,
    i_Fmt    Varchar2 := NULL
  ),

  -- Добавить логическое значение в текущий список
  final member procedure Add_Elem (
    Self in out nocopy JSON_String_T,
    i_Value  Boolean
  ),

  -- Вставить длинную строку в текущий объект JSON в качестве строки
  final member procedure Add_Elem (
    Self in out nocopy JSON_String_T,
    i_Value  Long_String
  ),

  -- Вставить объект JSON в текущий список
  final member procedure Add_Elem (
    Self in out nocopy JSON_String_T,
    i_Value  JSON_String_T
  ),

  -- Вставить коллекцию строк в текущий список в качестве вложенного списка значений
  -- В параметре i_Types можно передавать типы значений элементов коллекции
  -- Если коллекция содержит больше элементов, чем длина параметра i_Types, то для
  -- оставшихся элементов тип будет как "s" (строка, пустые строки вставляются как
  -- "null"). Неверные значения типов значений также заменяются на "s".
  -- ВНИМАНИЕ! В данной процедуре корректность числовых значений не проверяется!
  -- Параметры:
  --    i_Values - Коллекция значений списка
  --    i_Types  - Коллекция типов значений списка, где:
  --               S - строка, пустые строки вставляются как пустая строка ("")
  --               s - строка, пустые строки вставляются как нуль ("null")
  --               N - число, NULL-значения вставляются как пустая строка ("")
  --               n - число, NULL-значения вставляются как нуль ("null")
  --               B - логическое значение (true, false),
  --                   NULL-значения вставляются как пустая строка (""),
  --                   некорректные значения вставляются как ("false")
  --               b - логическое значение,
  --                   NULL-значения вставляются как нуль ("null"),
  --                   некорректные значения вставляются как строка
  --               Z - Вставить "null", соответствующее значение в коллекции игнорируется
  --               z - Вставить "null", если соответствующее значение в коллекции
  --                   не является "null" или NULL, то вставляется как строка
  --    i_Index  - Индекс элемента коллекции, с которой должна начинаться вставка
  --    i_Count  - Количество элементов для вставки (NULL - все элементы, начиная
  --               с позиции i_Index)
  final member procedure Add_Elem (
    Self in out nocopy JSON_String_T,
    i_Values  Array_Varchar2,
    i_Types   Varchar2       := NULL,
    i_Index   Simple_Integer := 1,
    i_Count   PLS_Integer    := NULL
  ),

  -- Добавить значение "null" в текущий список
  final member procedure Add_Null (Self in out nocopy JSON_String_T),

  -- Вставить коллекцию строк в текущий объект JSON в качестве единой строки
  final member procedure Add_As_String (
    Self in out nocopy JSON_String_T,
    i_Value  Array_Varchar2
  ),

  -- Вставить коллекцию строк в текущий список в виде вложенного списка
  final member procedure Add_As_Array (
    Self in out nocopy JSON_String_T,
    i_Value  Varchar2,
    i_Check  Boolean := True
  ),

  -- Вставить коллекцию строк в текущий список в виде вложенного списка
  final member procedure Add_As_Array (
    Self in out nocopy JSON_String_T,
    i_Value  Array_Varchar2,
    i_Check  Boolean       := True
  ),

  -- Вставить коллекцию строк в текущий список в виде кложенного объекта JSON
  final member procedure Add_As_JSON (
    Self in out nocopy JSON_String_T,
    i_Value  Varchar2,
    i_Check  Boolean := True
  ),

  -- Вставить коллекцию строк в текущий список в виде кложенного объекта JSON
  final member procedure Add_As_JSON (
    Self in out nocopy JSON_String_T,
    i_Value  Array_Varchar2,
    i_Check  Boolean       := True
  ),


  -- Присоединить заданную строку JSON к данному строку JSON
  -- Присоединяемая JSON-строка должна быть закрыта
  -- Присоединение другого объекта JSON допустимо только на уровне основного
  -- объекта JSON.
  -- При попытке выполнения процедуры присоединения во вложенных уровнях
  -- генерируетя исключение
  -- После присоединения закроет данную JSON-строку
  final member procedure Merge (
    Self in out nocopy JSON_String_T,
    i_JSON  JSON_String_T
  ),


  -- Возвращать значение в виде строки
  -- Если длина строки превышает 32К, то генерирует исключение
  final member function To_String Return Varchar2,

  -- Возвращать значение в виде коллекции данных в двоичном представлении
  final member function To_Raw_Array (i_Compress Varchar2 := NULL) Return Array_Raw,

  -- Возвращать значение в виде коллекции строк
  final member function To_String_Array Return Array_Varchar2,

  -- Возвращать значение в виде коллекции строк с заданной максимальной длиной элемента
  -- Добавлен от 27.11.2020
  final member function To_String_Array (i_Elem_Length PLS_Integer) Return Array_Varchar2,

  -- Возвращать значение в виде объекта CLOB
  final member function To_CLob Return CLob,

  -- Возвращать значение в виде объекта BLOB
  final member function To_BLob Return BLob,

  -- Возвращать значение в виде коллекции строк для отладочных целей
  final member function Debug Return Array_Varchar2

)
final;
/
CREATE OR REPLACE TYPE BODY "JSON_STRING_T"
is

  -- Статический метод для получения версии тела объектного типа
  -- Потомственые типы должны определять собственные методы для
  -- получения версии
  static function GetVersion return Varchar2
  is
  begin
    return '->>27112020<<-';
  end GetVersion;

  -- Конструктор для создания пустого экземпляра типа
  Constructor Function JSON_String_T (
    Self in out nocopy JSON_String_T
  )
  Return Self as Result
  is
  begin
    Self.Init();      -- Инициализировать атрибуты новой строки
    return;           -- Возврат
  end JSON_String_T;

  -- Инициализировать атрибуты новой строки
  final member procedure Init (Self in out nocopy JSON_String_T)
  is
  begin
    Self."Level "       := 1;              -- Уровень глубины текущего блока данных
    Self."Levels "      := 'O';            -- Типы блоков данных вложенных уровней
    Self."Length "      := 1;              -- Общая длина строки
    Self."Is_Empty "    := 'Y';            -- Текущий уровень еще пуст
    Self."Compress "    := 'Y';            -- Сжать строку при переносе на расширенный буфер
    Self."Max_Length "  := 256*1024*1024;  -- Допустимая длина строки (по умолчанию 256М)
    Self."Buf "         := '{';            -- Основной буфер для хранения JSON-строки
    Self."Raw_Data "    := NULL;           -- Расширенный буфер (инициализируется только при необходимости)
    --
    -- Инициализировать соглашения по форматированию данных
    Self.Set_Formats (
      i_Def_CharSet => 'CL8MSWIN1251',
      i_Fmt_Number  => 'FM99999999999999999990.99999999999999999999',
      i_Fmt_Date    => 'dd.mm.yyyy',
      i_Fmt_Time    => 'dd.mm.yyyy hh24:mi:ss');
    -- Инициализировать соглашения по значениям по умолчению
    Self.Set_Defaults (
      i_Null_Number  => '""',     -- Заменить числовое значение NULL на "0"
      i_Null_Boolean => '""',     -- Заменить булевское значение NULL на "false"
      i_Null_Date    => '""');    -- Заменить NULL-дату на пустую строку
  end Init;

  -- Инициализировать соглашения по форматированию данных
  final member procedure Set_Formats (
    Self in out nocopy JSON_String_T,
    i_Def_CharSet  Varchar2 := NULL,     -- Кодировка символов по умолчанию
    i_Fmt_Number   Varchar2 := NULL,     -- Формат значений числового типа
    i_Fmt_Date     Varchar2 := NULL,     -- Формат значений типа дата
    i_Fmt_Time     Varchar2 := NULL      -- Формат значений типа дата и время
  )
  is
  begin
    -- Инициализировать соглашения по форматированию данных
    Self."Def_CharSet " := NVL(i_Def_CharSet, Self."Def_CharSet ");  -- Кодировка символов по умолчанию
    Self."Fmt_Number "  := NVL(i_Fmt_Number,  Self."Fmt_Number ");   -- Формат значений числового типа
    Self."Fmt_Date "    := NVL(i_Fmt_Date,    Self."Fmt_Date ");     -- Формат значений типа дата
    Self."Fmt_Time "    := NVL(i_Fmt_Time,    Self."Fmt_Time ");     -- Формат значений типа дата и время
  end Set_Formats;

  -- Инициализировать соглашения о значениях по умолчению
  final member procedure Set_Defaults (
    Self in out nocopy JSON_String_T,
    i_Null_Number  Varchar2 := NULL,     -- Значение для замены NULL-числа
    i_Null_Boolean Varchar2 := NULL,     -- Значение для замены NULL-Boolean
    i_Null_Date    Varchar2 := NULL      -- Значение для замены NULL-даты
  )
  is
  begin
    -- Инициализировать соглашения по значениям по умолчению
    Self."Null_Number "  := NVL(i_Null_Number,  Self."Null_Number ");
    Self."Null_Boolean " := NVL(i_Null_Boolean, Self."Null_Boolean ");
    Self."Null_Date "    := NVL(i_Null_Date,    Self."Null_Date ");
  end Set_Defaults;

  -- Задать признак сжатии строки при переносе на расширенный буфер
  -- Установка данного значения в "Y" (по умолчанию) позволяет экономить
  -- оперативную память при незначительном снижении производительности
  final member procedure Set_Compress (
    Self in out nocopy JSON_String_T,
    i_Compress  Varchar2 := 'Y'
  )
  is
  begin
    -- Инициализировать соглашения по форматированию данных
    Self."Compress " := i_Compress;
  end Set_Compress;

  -- Установить новый предел для размера буфера
  -- Добавлен от 27.11.2020
  final member procedure Set_Max_Size (
    Self in out nocopy JSON_String_T,
    i_New_Size  Number                -- Новый предел для размера буфера
  )
  is
  begin
    -- Проверить допустимость заданного размера буфера
    if i_New_Size is NULL or i_New_Size < 1 then
      return;
    elsif i_New_Size < Self."Length " then
      Self."Max_Length " := Self."Length ";
    else
      Self."Max_Length " := i_New_Size;
    end if;
  end Set_Max_Size;

  -- Вызвать NULL-оператор
  -- Ничего не делает. Может вызываться для того, чтобы сделать компилятор довольным
  final member procedure Op_NULL (Self in JSON_String_T)
  is
  begin
    -- Добавим невыполняемый код, чтобы сделать компилятор довольным
    if Self is NULL then
      NULL;  -- Никогда не будет выполняться, но сделает компилятор довольным
    end if;
  end Op_NULL;

  -- Генерировать исключение с заданным  кодом ошибки и сообщением об ошибке
  final member procedure Error (
    Self          in JSON_String_T,
    i_Error_Code  in PLS_Integer := 0,
    i_Error_Msg   in Varchar2
  )
  is
  begin
    -- Генерировать исключение с заданным  кодом ошибки и сообщением об ошибке
    Raise_Application_Error(-20000 - i_Error_Code, i_Error_Msg || Chr(10) || 'Позиция: ' || Self."Length ");
    --
    Self.Op_NULL;    -- Сделаем компилятор довольным
  end Error;

  -- Возвращать длину строки
  final member function Get_Length Return Integer
  is
  begin
    return Self."Length ";
  end Get_Length;

  -- Возвращать уровень вложенности текущего блока
  final member function Get_Level Return Integer
  is
  begin
    return Self."Level ";
  end Get_Level;

  -- Возвращать количество внутренних буферов для хранения строки,
  -- включая основной и расширенные буфера
  final member function Get_Buf_Count Return Integer
  is
  begin
    return case when Self."Raw_Data " is NULL
             then 1 else Self."Raw_Data ".Count + 1
           end;
  end Get_Buf_Count;

  -- Клонировать текущую длинную строку
  final member function Cast_To_Raw (i_Str Varchar2) Return Raw
  is
  begin
    return UTL_i18n.String_To_Raw(i_Str, Self."Def_CharSet ");
  end Cast_To_Raw;

  -- Клонировать текущую длинную строку
  final member function Cast_To_String (i_Raw Raw) Return Varchar2
  is
  begin
    return UTL_i18n.Raw_To_Char(i_Raw, Self."Def_CharSet ");
  end Cast_To_String;

  -- Преобразовать заданную строку в JSON-совместимый формат
  -- Преобразует специальные символы в Escape-последовательности
  final static function Cast_To_JSON (i_Str Varchar2) return Varchar2
  is
  begin
    return Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(i_Str,
      '\', '\\'), '/', '\/'), '"', '\"'), Chr(8), '\b'), Chr(9), '\t'),
      Chr(10), '\r'), Chr(12), '\f'), Chr(13), '\n');
  end Cast_To_JSON;

  -- Упаковать строку в бинарном представлении
  final member function Compress_Raw (i_Raw Raw) Return Raw
  is
  begin
    return UTL_Compress.LZ_Compress(i_Raw);
  end Compress_Raw;

  -- Упаковать строку в символьном представлении
  final member function Compress_Str (i_Str Varchar2) Return Raw
  is
  begin
    return Self.Compress_Raw(UTL_i18n.String_To_Raw(i_Str, Self."Def_CharSet "));
  end Compress_Str;

  -- Распаковать сжатую строку и возвращать результат в бинарном представлении
  final member function Uncompress_To_Raw (i_Raw Raw) Return Raw
  is
  begin
    return UTL_Compress.LZ_Uncompress(i_Raw);
  end Uncompress_To_Raw;

  -- Распаковать сжатую строку и возвращать результат в символьном представлении
  final member function Uncompress_To_Str (i_Raw Raw) Return Varchar2
  is
  begin
    return UTL_i18n.Raw_To_Char(Self.Uncompress_To_Raw(i_Raw), Self."Def_CharSet ");
  end Uncompress_To_Str;

  -- Преобразовать значение символьного типа в формат JSON
  -- Вставит двойные кавычки на начало и конец строки
  -- Существующие в строке кавычки и специальные символы превращает в JSON-совместимые символы
  final member function Format (i_Str Varchar2) Return Varchar2
  is
  begin
    return '"' || JSON_String_T.Cast_To_JSON(i_Str) || '"';
  end Format;

  -- Преобразовать значение числового типа в формат JSON
  final member function Format (i_Value Number, i_Fmt Varchar2 := NULL) Return Varchar2
  is
  begin
    if i_Value is NULL then
      return NVL(Self."Null_Number ", '""');
    elsif Trunc(i_Value) = i_Value then
      return To_Char(i_Value, NVL(i_Fmt, 'FM99999999999999999999'));
    else
      return To_Char(i_Value, NVL(i_Fmt, Self."Fmt_Number "));
    end if;
  end Format;

  -- Преобразовать значение типа дата и время в формат JSON
  final member function Format (i_Value Date, i_Fmt Varchar2 := NULL) Return Varchar2
  is
  begin
    if i_Value is NULL then
      return NVL(Self."Null_Date ", '""');
    elsif i_Fmt is NULL and i_Value = Trunc(i_Value) then
      return '"' || To_Char(i_Value, Self."Fmt_Date ") || '"';
    else
      return '"' || To_Char(i_Value, NVL(i_Fmt, Self."Fmt_Time ")) || '"';
    end if;
  end Format;

  -- Преобразовать значение типа дата и время в формат JSON
  final member function Format (i_Value Boolean) Return Varchar2
  is
  begin
    if i_Value is NULL then
      return NVL(Self."Null_Boolean ", '""');
    elsif i_Value then
      return 'true';
    else
      return 'false';
    end if;
  end Format;


  -- Формировать пару ключ-значение для вставки в формате JSON
  -- При необходимостии вставить лидирующий запятой
  -- Только для внутреннего назначения
  final member function "_Make_Comma_Name " (i_Name Varchar2) Return Varchar2
  is
    v_Comma Varchar2(1) := case Self."Is_Empty "
                             when 'N' then ',' else ''
                           end;
  begin
    if SubStr(Self."Levels ", Self."Level ", 1) = 'O' then
      return v_Comma || Self.Format(i_Name) || ':';
    else
      return v_Comma;
    end if;
  end "_Make_Comma_Name ";

  -- Возвращать содержимое страницы буфера с заданным индексом в двоичном представлении
  -- Только для внутреннего назначения
  final member function "_Extract_Raw_Data " (
    i_Index      Integer,
    i_Compress   Varchar2 := 'Y',
    i_Debugging  Boolean  := False
  )
  Return Raw
  is
    v_Buf_Compr  Boolean     := (NVL(Self."Compress ", 'N') in ('Y', 'y'));
    v_Out_Compr  Boolean     := (NVL(i_Compress, 'Y') in ('Y', 'y'));
    v_Buf_Count  PLS_Integer := Self.Get_Buf_Count;
  begin
    --
    if Self."Level " > 0 and not i_Debugging then
      Self.Error(1, 'Для извлечения данных необходимо закрыть объект JSON!');
    elsif Self."Length " <= 1 or i_Index < 1 or i_Index > v_Buf_Count then
      -- Строка пуста, или задан неверный номер блока
      return NULL;     -- Возвращать пустое значение
    elsif i_Index = v_Buf_Count then
      -- Возвращать содержимое основного буфера
      return case when v_Out_Compr
               then Self.Compress_Str(Self."Buf ")
               else Self.Cast_To_Raw(Self."Buf ")
             end;
    elsif v_Buf_Compr = v_Out_Compr then
      -- Буфер уже упакован или упаковка не требуется
      return Self."Raw_Data "(i_Index);
    elsif v_Buf_Compr then
      -- Буфер упакован, необходимо распаковать
      return Self.Uncompress_To_Raw(Self."Raw_Data "(i_Index));
    else
      -- Буфер не упакован, необходимо упаковать
      return Self.Compress_Raw(Self."Raw_Data "(i_Index));
    end if;
  end "_Extract_Raw_Data ";

  -- Возвращать содержимое страницы буфера с заданным индексом в виде строки
  -- Только для внутреннего назначения
  final member function "_Extract_String " (
    i_Index      Integer,
    i_Debugging  Boolean  := False
  )
  Return Varchar2
  is
  begin
    if Self."Level " > 0 and not i_Debugging then
      Self.Error(2, 'Для извлечения данных необходимо закрыть объект JSON!');
    elsif Self."Raw_Data " is NULL or i_Index < 1 or i_Index > Self."Raw_Data ".Count then
      -- Возвращать содержимое основного буфера
      return Self."Buf ";
    elsif Self."Compress " in ('Y', 'y') then
      -- Буфер упакован, необходимо распаковать
      return Self.Cast_To_String(Self.Uncompress_To_Raw(Self."Raw_Data "(i_Index)));
    else
      -- Буфер не упакован
      return Self.Cast_To_String(Self."Raw_Data "(i_Index));
    end if;
  end "_Extract_String ";

  -- Инициализировать атрибуты новой строки
  -- Только для внутреннего назначения
  final member procedure "_Flash_Buf " (Self in out nocopy JSON_String_T)
  is
    v_Ind  PLS_Integer;
  begin
    -- Ничего не делать, если основной буфер пуст
    if Self."Buf " is NULL then
      return;
    elsif Self."Length " + 32767 > Self."Max_Length " then
      -- Превышена максимально допустимая длина JSON-строки
      Raise_Application_Error(-20000, 'Превышена допустимая длина JSON-строки (' || Self."Max_Length " || ')!');
    elsif Self."Raw_Data " is NULL then
      -- Инициализировать расширенный буфер
      Self."Raw_Data " := Array_Raw();
    end if;
    -- Расширить расширенный буфер
    Self."Raw_Data ".Extend;
    v_Ind := Self."Raw_Data ".Count;
    --
    -- Перенести содержимое основного буфера в расширенный буфер
    if Self."Compress " = 'Y' then
      -- Перенести со сжатием
      Self."Raw_Data "(v_Ind) := UTL_Compress.LZ_Compress(Self.Cast_To_Raw(Self."Buf "));
    else
      -- Перенести без сжатия
      Self."Raw_Data "(v_Ind) := UTL_i18n.String_To_Raw(Self."Buf ");
    end if;
    -- Сбросить основной буфер
    Self."Buf " := '';
  end "_Flash_Buf ";

  -- Инициализировать атрибуты новой строки
  -- Только для внутреннего назначения
  final member procedure "_Append_Str " (
    Self in out nocopy JSON_String_T,
    i_Str  Varchar2
  )
  is
    v_Str_Len  PLS_Integer := NVL(LengthB(i_Str), 0);
  begin
    -- Удостовериться, что JSON-строка открыта
    if Self."Level " <= 0 then  -- Специально дублирован код метода Is_Closed
      Self.Check_Open();        -- Для генерации ошибки используем метод Check_Open
    end if;
    -- Если размер буфера не позволяет вставку строки
    if v_Str_Len + LengthB(Self."Buf ") > 32767 then
      -- Перенести содержимое основного буфера в расширенный буфер
      Self."_Flash_Buf "();
      -- Вставить строку в основной буфер
      Self."Buf " := i_Str;
    else
      -- Добавить строку в конец основного буфера
      Self."Buf " := Self."Buf " || i_Str;
    end if;
    -- Изменить размер JSON-строки
    Self."Length " := Self."Length " + v_Str_Len;
  end "_Append_Str ";

  -- Вставить объект JSON в текущий объект JSON в качестве значения ключа
  -- Только для внутреннего назначения
  final member procedure "_Append_JSON " (
    Self in out nocopy JSON_String_T,
    i_Key    Varchar2,
    i_Value  JSON_String_T
  )
  is
    v_Comma  Varchar2(1) := case Self."Is_Empty "
                              when 'N' then ',' else ''
                            end;
  begin
    -- Удостовериться, что вставляемый объект JSON не открыть
    if i_Value is not NULL and not i_Value.Is_Closed() then
      Self.Error(15, 'Попытка вставки не закрытой JSON-строки!');  -- Строка не закрыта
    elsif i_Key is not NULL then
      -- Вставка в объект - добавить ключ и двоеточие
      Self."_Append_Str " (v_Comma || Self.Format(i_Key) || ':');
    elsif v_Comma is not NULL then
      -- Вставка в список - добавить запятую
      Self."_Append_Str " (v_Comma);
    end if;
    --
    if i_Value is NULL then
      -- Вставить пустой объект
      Self."_Append_Str " ('{}');
    else
      -- Добавить страницы буфера вставляемого объекта
      for I in 1..i_Value.Get_Buf_Count - 1
      loop
        Self."_Append_Str " (i_Value."_Extract_String "(I));
      end loop;
      -- Добавить основной буфер вставляемого объекта
      Self."_Append_Str " (i_Value."Buf ");
    end if;
    -- Отменить признак пустоты объекта
    Self."Is_Empty " := 'N';
  end "_Append_JSON ";

  -- Открыть новый блок данных JSON
  -- Только для внутреннего назначения
  final member procedure "_Open_New_Level " (
    Self in out nocopy JSON_String_T,
    i_Open_Char  Varchar2,
    i_Type_Char  Varchar2,
    i_Name       Varchar2 := NULL
  )
  is
  begin
    -- Проверить количество уровней вложенности
    if Self."Level " >= 32767 then
      Self.Error(5, 'Слишком много уровней вложенности объектов!');
    end if;
    -- Открыть новый блок данных JSON
    Self."_Append_Str "(Self."_Make_Comma_Name "(i_Name) || i_Open_Char);
    --
    Self."Level "      := Self."Level " + 1;
    Self."Levels "     := Self."Levels " || i_Type_Char;
    -- Установить признак пустоты уровня
    Self."Is_Empty "   := 'Y';
  end "_Open_New_Level ";

  -- Закрыть текущий блок данных JSON
  -- Только для внутреннего назначения
  final member procedure "_Close_Cur_Level " (
    Self in out nocopy JSON_String_T,
    i_Close_Char  Varchar2,
    i_Type_Char   Varchar2
  )
  is
  begin
    -- Проверить тип и состояние уровня
    Self.Check_Level(i_Type_Char, 'C');
    -- Закрыть текущий блок данных JSON
    Self."_Append_Str "(i_Close_Char);
    --
    Self."Level "      := Self."Level " - 1;
    Self."Levels "     := SubStr(Self."Levels ", 1, Self."Level ");
    -- Отменить признак пустоты уровня
    Self."Is_Empty "   := 'N';
  end "_Close_Cur_Level ";

  -- Добавить подготовленное значение в список
  -- Только для внутреннего назначения
  final member procedure "_Put_In_List " (
    Self in out nocopy JSON_String_T,
    i_Quoted_Value  Varchar2
  )
  is
    v_Comma  Varchar2(1) := case Self."Is_Empty "
                              when 'N' then ',' else ''
                            end;
  begin
    -- Удостовериться, что значение вставляется в список
    Self.Check_Level('L', 'L');
    --
    -- Добавить значение в конец буфера
    Self."_Append_Str " (v_Comma || i_Quoted_Value);
    -- Отменить признак пустоты списка
    Self."Is_Empty " := 'N';
  end "_Put_In_List ";

  -- Добавить подготовленную пару ключ-значение в объект JSON
  -- Только для внутреннего назначения
  final member procedure "_Put_In_Object " (
    Self in out nocopy JSON_String_T,
    i_Quoted_Key    Varchar2,
    i_Quoted_Value  Varchar2
  )
  is
    v_Comma  Varchar2(1) := case Self."Is_Empty "
                              when 'N' then ',' else ''
                            end;
  begin
    -- Удостовериться, что пара ключ-значение вставляется в JSON-объект
    Self.Check_Level('O', 'O');
    --
    -- Добавить пару ключ-значение в конец буфера
    Self."_Append_Str " (v_Comma || i_Quoted_Key || ':' || i_Quoted_Value);
    -- Отменить признак пустоты объекта
    Self."Is_Empty " := 'N';
  end "_Put_In_Object ";

  -- Добавить длинную строку в объект или список
  -- Только для внутреннего назначения
  final member procedure "_Put_Long_String " (
    Self in out nocopy JSON_String_T,
    i_Level  Varchar2,
    i_Key    Varchar2,
    i_Value  Array_Varchar2
  )
  is
    v_Index  PLS_Integer     := 0;
    v_Head   Varchar2(32767) := case Self."Is_Empty "
                                  when 'N' then ',' else ''
                                end;
  begin
    -- Удостовериться, что значение вставляется в список
    Self.Check_Level(i_Level, i_Level);
    --
    if i_Level = 'O' then
      v_Head := v_Head || Self.Format(i_Key) || ':';
    end if;
    --
    if i_Value is NULL or i_Value.Count = 0 then
      -- Добавить значение в конец буфера
      Self."_Append_Str " (v_Head || '""');
    else
      -- Добавить значение в конец буфера
      --Self."_Append_Str " (v_Head); -- edited by Ilhom Inoyatov
      -- value ni qo'yish uchun key dan kyn 1 ta qo'shtirnoqni qo'yamiz
      Self."_Append_Str " (v_Head || '"');
      --
      loop
        --
        v_Index := i_Value.Next(v_Index);
        exit when (v_Index is NULL);
        --
        if LengthB(i_Value(v_Index)) > 16383 then
          /*
           Ilhom Inoyatov: shu qismini komentariya qildim, sababi " -> shunaqa simvol qo'shib yuborayapti format funksiyasi
          Self."_Append_Str " (Self.Format(SubStrB(i_Value(v_Index), 1, 16383)));
          Self."_Append_Str " (Self.Format(SubStrB(i_Value(v_Index), 16384)));
          */
          Self."_Append_Str " (SubStrB(i_Value(v_Index), 1, 16383));
          Self."_Append_Str " (SubStrB(i_Value(v_Index), 16384));
        else
          /*
           Ilhom Inoyatov: shu qismini komentariya qildim, sababi " -> shunaqa simvol qo'shib yuborayapti format funksiyasi
          Self."_Append_Str " (Self.Format(i_Value(v_Index)));
          */
          Self."_Append_Str " (i_Value(v_Index));
        end if;
      end loop;
      -- Added by Ilhom Inoyatov
      -- value ni qiymatini qo'yib bo'lganimizdan kyn qo'shtirnoqni yopib qoyamiz
      Self."_Append_Str " ('"');
    end if;
    -- Отменить признак пустоты списка
    Self."Is_Empty " := 'N';
  end "_Put_Long_String ";

  -- Вставить тело готового объекта JSON или списка JSON
  -- Тело объекта/списка вставляется без проверки на корректность
  -- Только для внутреннего назначения
  final member procedure "_Put_Object_Body " (
    Self in out nocopy JSON_String_T,
    i_Key        Varchar2,
    i_Obj_Body   Array_Varchar2,
    i_Level_Type Varchar2
  )
  is
    v_Index  PLS_Integer := 0;
    v_Str    Varchar2(32767) := case Self."Is_Empty "
                                  when 'N' then ',' else ''
                                end;
  begin
    -- Удостовериться, что значение вставляется в объект заданного типа
    Self.Check_Level(i_Level_Type, i_Level_Type);
    --
    if i_Level_Type = 'O' then
      -- Добавить пару ключ-значение в конец буфера
      v_Str := v_Str || Self.Format(i_Key) || ':';
    elsif i_Level_Type != 'L' then
      -- Неверный тип родительского объекта - генерировать исключение
      Self.Error(3, 'Синтаксическая ошибка!');
    end if;
    --
    if i_Obj_Body is NULL or i_Obj_Body.Count = 0 then
      -- Добавить значение в конец буфера
      Self."_Append_Str " (v_Str || '""');
    else
      -- Добавить значение в конец буфера
      Self."_Append_Str " (v_Str);
      -- Вставить элементы коллекции
      loop
        -- Получить индекс следующего элемента коллекции
        v_Index := i_Obj_Body.Next(v_Index);
        exit when (v_Index is NULL);
        -- Добавить значение в конец буфера
        Self."_Append_Str " (i_Obj_Body(v_Index));
      end loop;
    end if;
    -- Отменить признак пустоты списка
    Self."Is_Empty " := 'N';
  end "_Put_Object_Body ";

  -- Процедура пакетной вставки списка значений в буфер
  -- В параметре i_Types можно передавать типы значений элементов коллекции
  -- Если коллекция содержит больше элементов, чем длина параметра i_Types, то для
  -- оставшихся элементов тип будет как "s" (строка, пустые строки вставляются как
  -- "null"). Неверные значения типов значений также заменяются на "s".
  -- ВНИМАНИЕ! В данной процедуре корректность числовых значений не проверяется!
  -- Параметры:
  --    i_Values - Коллекция значений списка
  --    i_Types  - Коллекция типов значений списка, где:
  --               S - строка, пустые строки вставляются как пустая строка ("")
  --               s - строка, пустые строки вставляются как нуль ("null")
  --               N - число, NULL-значения вставляются как пустая строка ("")
  --               n - число, NULL-значения вставляются как нуль ("null")
  --               B - логическое значение (true, false),
  --                   NULL-значения вставляются как пустая строка (""),
  --                   некорректные значения вставляются как ("false")
  --               b - логическое значение,
  --                   NULL-значения вставляются как нуль ("null"),
  --                   некорректные значения вставляются как строка
  --               Z - Вставить "null", соответствующее значение в коллекции игнорируется
  --               z - Вставить "null", если соответствующее значение в коллекции
  --                   не является "null" или NULL, то вставляется как строка
  --    i_Index  - Индекс элемента коллекции, с которой должна начинаться вставка
  --    i_Count  - Количество элементов для вставки (NULL - все элементы, начиная
  --               с позиции i_Index)
  -- Только для внутреннего назначения
  final member procedure "_Put_Array " (
    Self in out nocopy JSON_String_T,
    i_Key     Varchar2,
    i_Values  Array_Varchar2,
    i_Types   Varchar2,
    i_Index   Simple_Integer := 1,
    i_Count   PLS_Integer    := NULL
  )
  is
    v_Ind   PLS_Integer    := i_Index - 1;
    v_Pos   Simple_Integer := 0;
    v_Count Simple_Integer := 0;
    v_Buf   Varchar2(32767);
    v_Value Varchar2(32767);
    v_Type  Varchar2(1);
  begin
    -- Открыть новый список
    Self.Open_Array(i_Key);
    -- Если список не пуст, то вставит элементы списка по типам
    if i_Values is not NULL and i_Values.Count > 0 then
      --
      v_Count := NVL(i_Count, i_Values.Count);
      -- Цикл по всем элементам списка
      loop
        v_Ind := i_Values.Next(v_Ind);
        exit when (v_Ind is NULL or v_Pos >= v_Count);
        --
        v_Pos  := v_Pos + 1;
        v_Type := NVL(SubStr(i_Types, v_Pos, 1), 's');
        --
        if i_Values(v_Ind) is NULL then
          v_Value := case when v_Type in ('S', 'N', 'B')
                       then '""' else 'null'
                     end;
        else
          --
          if v_Type in ('S', 's') then
            v_Value := '"' || JSON_String_T.Cast_To_JSON(i_Values(v_Ind)) || '"';
          elsif v_Type in ('N', 'n') then
            v_Value := i_Values(v_Ind);
          elsif v_Type in ('B', 'b') then
            --
            v_Value := i_Values(v_Ind);
            if v_Value not in ('true', 'false') then
              if v_Type = 'B' then
                v_Value := 'false';
              else
                v_Value := '"' || JSON_String_T.Cast_To_JSON(i_Values(v_Ind)) || '"';
              end if;
            end if;
          elsif v_Type in ('Z', 'z') then
            v_Value := 'null';
            --
            if v_Type = 'z' and i_Values(v_Ind) != 'null' then
              v_Value := '"' || JSON_String_T.Cast_To_JSON(i_Values(v_Ind)) || '"';
            end if;
          end if;
        end if;
        --
        if v_Pos = 1 then
          v_Buf := v_Value;
        elsif LengthB(v_Buf) + LengthB(v_Value) >= 32767 then    -- Беферизовать по 32Кб
          -- Вставить содержимое буфера
          Self."_Append_Str " (v_Buf);
          v_Buf := ',' || v_Value;
        else
          v_Buf := v_Buf || ',' || v_Value;
        end if;
      end loop;
      -- Добавить значение в конец буфера
      Self."_Append_Str " (v_Buf);
    end if;
    -- Закрыть список
    Self.Close_Array();
  end "_Put_Array ";

  -- Удостовериться, что заданная коллекция строк содержит синтаксически корректное
  -- описание (тело) объекта или списка JSON
  final member Procedure "_Check_Syntax " (
    Self in JSON_String_T,
    i_JSON  Array_Varchar2,
    i_Type  Varchar2
  )
  is
    v_Page        Simple_Integer := 1;
    v_Index       Simple_Integer := 0;
    v_Buf_Size    Simple_Integer := 0;
    v_Page_Count  Simple_Integer := 0;
    v_Token       Varchar2(1);
    v_Token_Char  Varchar2(1);
    v_Token_Page  Simple_Integer := 0;
    v_Token_Index Simple_Integer := 0;


    -- Синтаксическая проверка блока объекта JSON
    Procedure Check_Object;

    -- Синтаксическая проверка блока массива JSON
    Procedure Check_Array;

    -- Генерировать исключение с заданным  кодом ошибки и сообщением об ошибке
    Procedure Syntax_Error (
      i_Page     Simple_Integer := v_Token_Page,
      i_Index    Simple_Integer := v_Token_Index,
      i_Err_Code Simple_Integer := 0,
      i_Err_Msg  Varchar2       := ''
    )
    is
    begin
      -- Генерировать исключение с заданным  кодом ошибки и сообщением об ошибке
      Raise_Application_Error(-20000 - i_Err_Code, 'Синтаксическая ошибка: ' || i_Err_Msg
          || Chr(10) || 'Строка: ' || i_Page || ', Позиция: ' || i_Index);
    end Syntax_Error;

    -- Полцучить индекс следующей не пустой страницы буфера
    Function Get_Next_Page (i_Page Simple_Integer) Return Simple_Integer
    is
      P  Simple_Integer := i_Page;
    begin
      -- Перейти к следующей не пустой странице буфера
      while (P < v_Page_Count)
      loop
        -- Перейти к следующей странице
        P := P + 1;
        -- Возвращать индекс страницы, если она не пуста
        if i_JSON(P) is not NULL then
          return P;
        end if;
      end loop;
      -- Достигнут конец буфера
      return 0;
    end Get_Next_Page;

    -- Полцучить индекс предыдущей не пустой страницы буфера
    Function Get_Prev_Page (i_Page Simple_Integer) Return Simple_Integer
    is
      P  Simple_Integer := i_Page;
    begin
      -- Перейти к предыдущей не пустой странице буфера
      while (P > 1)
      loop
        -- Перейти к предыдущей странице
        P := P - 1;
        -- Возвращать индекс страницы, если она не пуста
        if i_JSON(P) is not NULL then
          return P;
        end if;
      end loop;
      -- Достигнут начало буфера
      return 0;
    end Get_Prev_Page;

    -- Переместить заданный указатель к началу следующей или к конец предыдущей не пустой страницы
    Function Move_Page (
      io_Page  in out Simple_Integer,
      io_Index in out Simple_Integer,
      i_Prev   in     Boolean       := False
    )
    Return Boolean
    is
      P  Simple_Integer := 0;
    begin
      if i_Prev then
        P := Get_Prev_Page(io_Page);
      else
        P := Get_Next_Page(io_Page);
      end if;
      if P > 0 then
        io_Page := P;
        if i_Prev then
          io_Index := Length(i_JSON(P));
        else
          io_Index := 1;
        end if;
        return True;
      else
        return False;
      end if;
    end Move_Page;

    -- Перенести текущий указатель на конец буфера
    Procedure Finished
    is
    begin
      v_Page     := v_Page_Count;
      v_Buf_Size := NVL(Length(i_JSON(v_Page)), 0);
      v_Index    := v_Buf_Size + 1;
    end Finished;

    -- Извлекать из буфера следующий символ без переноса текущего указателя
    Function Get_Next_Char Return Varchar2
    is
      P  Simple_Integer := v_Page;
      I  Simple_Integer := v_Index;
    begin
      -- Если еще не достигнуть конец страницы буфера
      if I < v_Buf_Size then
        -- Перевести текущий указатель к следующему символу
        return SubStr(i_JSON(P), I + 1, 1);
      elsif Move_Page(P, I) then
        -- Перевести текущий указатель к началу следующей страницы
        return SubStr(i_JSON(P), I, 1);
      else
        -- Конец буфера
        return NULL;
      end if;
    end Get_Next_Char;

    -- Извлекать из буфера предыдущий символ без переноса текущего указателя
    Function Get_Prev_Char Return Varchar2
    is
      P  Simple_Integer := v_Page;
      I  Simple_Integer := v_Index;
    begin
      -- Если еще не достигнуть конец страницы буфера
      if v_Index > 1 then
        -- Перевести текущий указатель к следующему символу
        return SubStr(i_JSON(P), I - 1, 1);
      elsif Move_Page(P, I, True) then
        -- Перевести текущий указатель к началу следующей страницы
        return SubStr(i_JSON(P), I, 1);
      else
        -- Конец буфера
        return NULL;
      end if;
    end Get_Prev_Char;

    -- Извлекать из буфера следующий символ без переноса текущего указателя
    Function Get_String (
      i_Page1   Simple_Integer,
      i_Index1  Simple_Integer,
      i_Page2   Simple_Integer,
      i_Index2  Simple_Integer
    )
    Return Varchar2
    is
      P      Simple_Integer := i_Page1 + 1;
      Result Varchar2(32767);
    begin
      --
      if i_Page1 = i_Page2 then
        return SubStr(i_JSON(i_Page1), i_Index1, i_Index2 - i_Index1 + 1);
      elsif i_Page1 > i_Page2 then
        return NULL;
      end if;
      --
      Result := SubStr(i_JSON(i_Page1), i_Index1);
      --
      while P < i_Page2
      loop
        Result := Result || i_JSON(P);
        P := P + 1;
      end loop;
      --
      return Result || SubStr(i_JSON(i_Page2), 1, i_Index2);
    end Get_String;

    -- Извлекать из буфера следующий символ с переносом текущего указателя
    Function Next_Char Return Varchar2
    is
    begin
      -- Если еще не достигнуть конец страницы буфера
      if v_Index < v_Buf_Size then
        -- Перевести текущий указатель к следующему символу
        v_Index := v_Index + 1;
      elsif Move_Page(v_Page, v_Index) then
        -- Перевести текущий указатель к началу следующей страницы
        v_Buf_Size := Length(i_JSON(v_Page));
      else
        -- Перенести текущий указатель на конец буфера и возвращать NULL
        Finished;
        return NULL;
      end if;
      -- Возвращать символ
      return SubStr(i_JSON(v_Page), v_Index, 1);
    end Next_Char;

    -- Пропустить символ
    Procedure Skip_Char
    is
    begin
      -- Если еще не достигнуть конец страницы буфера
      if v_Index < v_Buf_Size then
        -- Перевести текущий указатель к следующему символу
        v_Index := v_Index + 1;
      elsif Move_Page(v_Page, v_Index) then
        -- Перевести текущий указатель к началу следующей страницы
        v_Buf_Size := Length(i_JSON(v_Page));
      else
        -- Перенести текущий указатель на конец буфера
        Finished;
      end if;
    end Skip_Char;

    -- Подать текущий символ обратно во вход
    Procedure Put_Char_Back
    is
    begin
      -- Если еще не достигнуть начало буфера
      if v_Index > 1 then
        -- Перевести текущий указатель к предыдующему символу
        v_Index := v_Index - 1;
      elsif Move_Page(v_Page, v_Index, True) then
        -- Перевести текущий указатель к началу следующей страницы
        v_Buf_Size := Length(i_JSON(v_Page));
      else
        -- Перенести текущий указатель на конец буфера
        v_Page     := 1;
        v_Index    := 0;
        v_Buf_Size := NVL(Length(i_JSON(v_Page)), 0);
      end if;
    end Put_Char_Back;

    -- Найти в буфере заданную подстроку или его альрернативу
    Function Find_Str (i_Str Varchar2, i_Alt_Str Varchar2 := NULL) Return Boolean
    is
      P  Simple_Integer := v_Page;
      I  Simple_Integer := v_Index + 1;
    begin
      loop
        -- Найти заданную основноу подстроку
        I := InStr(i_JSON(P), i_Str, I);
        -- Если подстрока не найдена и задана альтернативная подстрока, то найти его
        if I = 0 and i_Alt_Str is not NULL then
          I := InStr(i_JSON(P), i_Alt_Str, I);
        end if;
        -- Если подстрока найдена
        if I > 0 then
          -- Переместить текущий указатель на позицию подстроки
          v_Page  := P;
          v_Index := I;
          -- Подстрока найдена - возвращать "Истина"
          return True;
        end if;
        -- Звершить поиск, если достигнут конец буфера
        exit when (P >= v_Page_Count);
        -- Перейти на начало следующей страницы буфера
        P := P + 1;
        I := 1;
      end loop;
      -- Подстрока не найдена - возвращать "Ложь"
      return False;
    end Find_Str;

    -- Игнорировать блочный комментарий
    Procedure Skip_Block_Comment
    is
    begin
      -- Найти закрывающую комментарий пару символов
      if not Find_Str ('*'||'/') then
        -- Не закрыть блочный комментарий!
        Syntax_Error('Синтаксическая ошибка: не закрыть блочный комментарий!');
      end if;
    end Skip_Block_Comment;

    -- Игнорировать строчный комментарий
    Procedure Skip_Line_Comment
    is
    begin
      -- Найти символ или пару символов конца строки
      if Find_Str(Chr(10), Chr(13)) then
        -- Пропустить символы конца строки
        while Get_Next_Char in (Chr(10), Chr(13))
        loop
          Skip_Char;
        end loop;
      else
        -- Перенести текущий указатель на конец буфера
        Finished;
      end if;
    end Skip_Line_Comment;

    -- Пропустить комментарии, пробелы и другие "белые" символы
    Procedure Skip_Blanks_And_Comments
    is
      v_Ch  Varchar2(1);
    begin
      -- Пропустить пробелы и другие "белые" символы
      loop
        -- Извлекать из буфера очередной символ
        v_Ch := Next_Char;
        -- Выйти, если символ не является "белым"
        exit when v_Ch is NULL or v_Ch not in (' ', Chr(9), Chr(10), Chr(13));
      end loop;
      -- Если найден символ '/'
      if v_Ch = '/' then
        -- Исследовать следующий символ
        v_Ch := Get_Next_Char;
        -- Если это комментарий, то пропустить
        if v_Ch = '/' then
          Skip_Line_Comment;
          Skip_Blanks_And_Comments;
        elsif v_Ch = '*' then
          Skip_Block_Comment;
          Skip_Blanks_And_Comments;
        end if;
      end if;
    end Skip_Blanks_And_Comments;

    -- Извлекать очередную лексему
    Procedure Get_Token
    is
    begin
      -- Извлекать очереднуой символ
      v_Token := Next_Char;
      -- Если получен "белый" символ или символ комментария
      if v_Token in (' ', Chr(9), Chr(10), Chr(13), '/') then
        -- Подать текущий символ обратно во вход
        Put_Char_Back;
        -- Пропустить комментарии, пробелы и другие "белые" символы
        Skip_Blanks_And_Comments;
        -- Извлекать из буфера текущий символ
        v_Token := SubStr(i_JSON(v_Page), v_Index, 1);
      end if;
      --
      -- Сохранить первый символ и позицию лексемы
      v_Token_Char  := v_Token;
      v_Token_Page  := v_Page;
      v_Token_Index := v_Index;
      --
      -- Разбирать и проверить лексему
      if v_Token is NULL then
        -- Конец буфера
        v_Token := 'F';
      elsif v_Token = '"' or v_Token = '''' then
        v_Token := 'S';
      elsif (v_Token >= '0' and v_Token <= '9') or v_Token in ('.', '+', '-') then
        v_Token := 'N';
      elsif (v_Token >= 'A' and v_Token <= 'Z') or (v_Token >= 'a' and v_Token <= 'z') or v_Token = '_' then
        v_Token := 'I';
      elsif v_Token not in (',', ':', '{', '}', '[', ']') then
        Syntax_Error;
      end if;
    end Get_Token;

    -- Проверить, достигнут ли конец блока
    Function Is_Block_End (i_Close_Char Varchar2) Return Boolean
    is
    begin
      -- Извлекать очередную лексему
      Get_Token;
      -- Разбирать и проверить лексему
      if v_Token = ',' then
        return False;
      elsif v_Token = i_Close_Char then
        return True;
      else
        Syntax_Error;
      end if;
    end Is_Block_End;

    -- Удостовериться, что очередной символ является ожидаемым символом
    Procedure Check_Symbol (i_Sym Varchar2)
    is
    begin
      -- Извлекать очередную лексему
      Get_Token;
      -- Разбирать и проверить лексему
      if v_Token != i_Sym then
        Syntax_Error;
      end if;
    end Check_Symbol;

    -- Синтаксическая проверка значения
    Procedure Check_Ident (i_Is_Value Boolean)
    is
      P      Simple_Integer := v_Token_Page;
      I      Simple_Integer := v_Token_Index;
      v_Ch   Varchar2(1);
      v_Name Varchar2(32767);
    begin
      -- Пропустить пробелы и другие "белые" символы
      loop
        -- Извлекать из буфера очередной символ
        v_Ch := Next_Char;
        -- Выйти, если символ не является "белым"
        exit when v_Ch is NULL;
        --
        exit when
          not ((v_Ch >= '0' and v_Ch <= '9') or (v_Ch >= 'A' and v_Ch <= 'Z') or
               (v_Ch >= 'a' and v_Ch <= 'z') or (v_Ch = '_'));
      end loop;
      -- Подать последний символ обратно во вход
      Put_Char_Back;
      --
      v_Name := Get_String(P, I, v_Page, v_Index);
      --
      if v_Name in ('true', 'false', 'null') then
        if not i_Is_Value then
          Syntax_Error;
        end if;
      elsif i_Is_Value then
        Syntax_Error;
      end if;
    end Check_Ident;

    -- Синтаксическая проверка значения
    Procedure Check_Number
    is
      v_Ch  Varchar2(1) := v_Token;
      v_Dot Boolean     := (v_Ch = '.');
    begin
      -- Если лексема является знаком "+" или "-"
      if v_Ch in ('.', '+', '-') then
        -- Игнорировать знак "+/-/."
        v_Ch := Next_Char;
        --
        if v_Dot and not (v_Ch >= '0' and v_Ch <= '9') then
          Syntax_Error;
        end if;
        -- Игнорировать пробелы
        while v_Ch in (' ', Chr(9))
        loop
          v_Ch := Next_Char;
        end loop;
        -- Подать последний символ обратно во вход
        Put_Char_Back;
      end if;
      -- Цикл для поиска конца цифрового значения
      loop
        -- Извлекать следующий символ
        v_Ch := Next_Char;
        --
        if v_Ch >= '0' and v_Ch <= '9' then
          -- Цифровой символ
          continue;
        elsif v_Ch = '.' then
          -- Плавающая точка
          if v_Dot then
            -- Повторная плавающая точка
            Syntax_Error;
          else
            v_Dot := True;
            continue;
          end if;
        end if;
        -- Конец цифры
        exit;
      end loop;
      -- Подать последний символ обратно во вход
      Put_Char_Back;
    end Check_Number;

    -- Синтаксическая проверка строки
    Procedure Check_String (i_Quote Varchar2)
    is
    begin
      -- Цикл для игнорирования парных кавычек
      loop
        -- Найти закрывающиеся кавычку
        if Find_Str(i_Quote) then
          --
          if Get_Next_Char = i_Quote then
            -- Игнорировать парные кавычки одинакового с внешними кавычками типа
            Skip_Char;
            continue;
          elsif Get_Prev_Char != '\' then   -- Игнорировать Escape-пару символов для кавычки
            -- Найден конец строки
            exit;
          end if;
        else
          -- Пропущена закрывающая кавычка!
          Syntax_Error;
        end if;
      end loop;
    end Check_String;

    -- Синтаксическая проверка значения
    Procedure Check_Value
    is
    begin
      -- Извлекать очередную лексему
      Get_Token;
      -- Разбирать и проверить лексему
      case v_Token
        when 'S' then Check_String(v_Token_Char);
        when 'N' then Check_Number;
        when 'I' then Check_Ident(True);
        when '{' then Check_Object;
        when '[' then Check_Array;
        else Syntax_Error;
      end case;
    end Check_Value;

    -- Синтаксическая проверка значения
    Procedure Check_Key_Value
    is
    begin
      -- Извлекать очередную лексему
      Get_Token;
      -- Разбирать и проверить лексему
      case v_Token
        when 'S' then Check_String(v_Token_Char);
        when 'I' then Check_Ident(False);
        else Syntax_Error;
      end case;
      -- Удостовериться, что очередной символ является символом ":"
      Check_Symbol(':');
      -- Синтаксическая проверка значения
      Check_Value;
    end Check_Key_Value;

    -- Синтаксическая проверка блока списка JSON
    Procedure Check_Array
    is
    begin
      -- Извлекать очередную лексему
      Get_Token;
      -- Разбирать и проверить лексему
      if v_Token = ']' then
        return;
      end if;
      -- Подать последний символ обратно во вход
      Put_Char_Back;
      -- Проверить все элементы списка
      loop
        -- Синтаксическая проверка значения
        Check_Value;
        -- Выйти из цикла, если достигнут конец списка
        exit when Is_Block_End(']');
      end loop;
    end Check_Array;

    -- Синтаксическая проверка блока объекта JSON
    Procedure Check_Object
    is
    begin
      -- Извлекать очередную лексему
      Get_Token;
      -- Разбирать и проверить лексему
      if v_Token = '}' then
        return;
      end if;
      -- Подать последний символ обратно во вход
      Put_Char_Back;
      -- Проверить все элементы объекта
      loop
        -- Синтаксическая проверка пары ключ-значение
        Check_Key_Value;
        -- Выйти из цикла, если достигнут конец списка
        exit when Is_Block_End('}');
      end loop;
    end Check_Object;

  begin
    -- Генерировать исключение, если буфер не инициализирован
    if i_JSON is NULL or i_JSON.Count = 0 then
      Raise_Application_Error(-20000, 'Не задана JSON-строка!');
    end if;
    --
    v_Page_Count := i_JSON.Count;
    v_Page       := Get_Next_Page(0);
    --
    if v_Page > 0 then
      -- Установить размер текущей страницы буфера
      v_Buf_Size := Length(i_JSON(v_Page));
    else
      -- Буфер пуст - генерировать исключение
      Raise_Application_Error(-20000, 'Задана пустая строка вместо JSON-строки!');
    end if;
    --
    -- Синтаксическая проверка объекта заданного типа
    if i_Type = 'O' then
      -- Удостовериться, что очередная лексема является символом "{"
      Check_Symbol('{');
      -- Проверить тело объекта JSON
      Check_Object;
    elsif i_Type = 'L' then
      -- Удостовериться, что очередная лексема является символом "["
      Check_Symbol('[');
      -- Проверить тело списка (массива) JSON
      Check_Array;
    else
      -- Буфер пуст - генерировать исключение
      Raise_Application_Error(-20000, 'Некорректный вызов внутреннего метода!');
      --
      Self.Op_NULL;    -- Сделаем компилятор довольным
    end if;
    -- Генерировать исключение, если не достигнут конец буфера
    if v_Page < v_Page_Count or v_Index < v_Buf_Size then
      -- Не достигнут конец буфера - генерировать исключение
      Raise_Application_Error(-20000, 'Символы после завершения JSON-строки недопустимы!');
    end if;
  end "_Check_Syntax ";

/*
  -- Удостовериться, что заданная коллекция строк содержит синтаксически корректное
  -- описание (тело) объекта или списка JSON
  final member Procedure "_Check_Syntax " (
    Self in JSON_String_T,
    i_Buf       in Varchar2,
    i_Type      in Varchar2,
    i_Is_Last   in Boolean,
    io_Status   in out nocopy PLS_Integer,
    io_Levels   in out nocopy Varchar2,
    io_Token    in out nocopy Varchar2,
    io_Token_Ch in out nocopy Varchar2,
    io_Buf      in out nocopy Varchar2
  )
  is
    v_Index       Simple_Integer := 0;
    v_Buf_Size    Simple_Integer := NVL(Length(i_Buf), 0);
    v_Token       Varchar2(1)    := io_Token;
    v_Token_Char  Varchar2(1)    := io_Token_Ch;
    v_Token_Index Simple_Integer := 0;


    -- Синтаксическая проверка блока объекта JSON
    Procedure Check_Object;

    -- Синтаксическая проверка блока массива JSON
    Procedure Check_Array;

    -- Генерировать исключение с заданным  кодом ошибки и сообщением об ошибке
    Procedure Syntax_Error (
      i_Page     Simple_Integer := 1,
      i_Index    Simple_Integer := v_Token_Index,
      i_Err_Code Simple_Integer := 0,
      i_Err_Msg  Varchar2       := ''
    )
    is
    begin
      -- Генерировать исключение с заданным  кодом ошибки и сообщением об ошибке
      Raise_Application_Error(-20000 - i_Err_Code, 'Синтаксическая ошибка: ' || i_Err_Msg
          || Chr(10) || 'Строка: ' || i_Page || ', Позиция: ' || i_Index);
    end Syntax_Error;

    -- Извлекать из буфера следующий символ без переноса текущего указателя
    Function Get_Next_Char Return Varchar2
    is
    begin
      -- Если еще не достигнут конец буфера
      if v_Index < v_Buf_Size then
        -- Возвращать следующий за текущим указателем символ
        return SubStr(i_Buf, v_Index + 1, 1);
      end if;
      -- Достигнут конец буфера
      return Chr(0);
    end Get_Next_Char;

    -- Извлекать из буфера предыдущий символ без переноса текущего указателя
    Function Get_Prev_Char Return Varchar2
    is
    begin
      -- Если еще не достигнут начало буфера
      if v_Index > 1 then
        -- Возвращать следующий за текущим указателем символ
        return SubStr(i_Buf, v_Index - 1, 1);
      end if;
      -- Достигнут начало буфера
      return Chr(1);
    end Get_Prev_Char;

    -- Извлекать из буфера следующий символ без переноса текущего указателя
    Function Get_String (
      i_Page1   Simple_Integer,
      i_Index1  Simple_Integer,
      i_Page2   Simple_Integer,
      i_Index2  Simple_Integer
    )
    Return Varchar2
    is
      P      Simple_Integer := i_Page1 + 1;
      Result Varchar2(32767);
    begin
      --
      if i_Page1 = i_Page2 then
        return SubStr(i_JSON(i_Page1), i_Index1, i_Index2 - i_Index1 + 1);
      elsif i_Page1 > i_Page2 then
        return NULL;
      end if;
      --
      Result := SubStr(i_JSON(i_Page1), i_Index1);
      --
      while P < i_Page2
      loop
        Result := Result || i_JSON(P);
        P := P + 1;
      end loop;
      --
      return Result || SubStr(i_JSON(i_Page2), 1, i_Index2);
    end Get_String;

/ *
    -- Перенести текущий указатель на конец буфера
    Procedure Finished
    is
    begin
      v_Index := v_Buf_Size + 1;
    end Finished;
* /

    -- Извлекать из буфера следующий символ с переносом текущего указателя
    Function Next_Char Return Varchar2
    is
    begin
      -- Если еще не достигнуть конец страницы буфера
      if v_Index < v_Buf_Size then
        -- Перевести текущий указатель к следующему символу
        v_Index := v_Index + 1;
      elsif Move_Page(v_Page, v_Index) then
        -- Перевести текущий указатель к началу следующей страницы
        v_Buf_Size := Length(i_JSON(v_Page));
      else
        -- Перенести текущий указатель на конец буфера и возвращать NULL
        Finished;
        return NULL;
      end if;
      -- Возвращать символ
      return SubStr(i_JSON(v_Page), v_Index, 1);
    end Next_Char;

    -- Пропустить символ
    Procedure Skip_Char
    is
    begin
      -- Если еще не достигнуть конец страницы буфера
      if v_Index < v_Buf_Size then
        -- Перевести текущий указатель к следующему символу
        v_Index := v_Index + 1;
      elsif Move_Page(v_Page, v_Index) then
        -- Перевести текущий указатель к началу следующей страницы
        v_Buf_Size := Length(i_JSON(v_Page));
      else
        -- Перенести текущий указатель на конец буфера
        Finished;
      end if;
    end Skip_Char;

    -- Подать текущий символ обратно во вход
    Procedure Put_Char_Back
    is
    begin
      -- Если еще не достигнуть начало буфера
      if v_Index > 1 then
        -- Перевести текущий указатель к предыдующему символу
        v_Index := v_Index - 1;
      elsif Move_Page(v_Page, v_Index, True) then
        -- Перевести текущий указатель к началу следующей страницы
        v_Buf_Size := Length(i_JSON(v_Page));
      else
        -- Перенести текущий указатель на конец буфера
        v_Page     := 1;
        v_Index    := 0;
        v_Buf_Size := NVL(Length(i_JSON(v_Page)), 0);
      end if;
    end Put_Char_Back;

    -- Найти в буфере заданную подстроку или его альрернативу
    Function Find_Str (i_Str Varchar2, i_Alt_Str Varchar2 := NULL) Return Boolean
    is
      P  Simple_Integer := v_Page;
      I  Simple_Integer := v_Index + 1;
    begin
      loop
        -- Найти заданную основноу подстроку
        I := InStr(i_JSON(P), i_Str, I);
        -- Если подстрока не найдена и задана альтернативная подстрока, то найти его
        if I = 0 and i_Alt_Str is not NULL then
          I := InStr(i_JSON(P), i_Alt_Str, I);
        end if;
        -- Если подстрока найдена
        if I > 0 then
          -- Переместить текущий указатель на позицию подстроки
          v_Page  := P;
          v_Index := I;
          -- Подстрока найдена - возвращать "Истина"
          return True;
        end if;
        -- Звершить поиск, если достигнут конец буфера
        exit when (P >= v_Page_Count);
        -- Перейти на начало следующей страницы буфера
        P := P + 1;
        I := 1;
      end loop;
      -- Подстрока не найдена - возвращать "Ложь"
      return False;
    end Find_Str;

    -- Игнорировать блочный комментарий
    Procedure Skip_Block_Comment
    is
    begin
      -- Найти закрывающую комментарий пару символов
      if not Find_Str ('*'||'/') then
        -- Не закрыть блочный комментарий!
        Syntax_Error('Синтаксическая ошибка: не закрыть блочный комментарий!');
      end if;
    end Skip_Block_Comment;

    -- Игнорировать строчный комментарий
    Procedure Skip_Line_Comment
    is
    begin
      -- Найти символ или пару символов конца строки
      if Find_Str(Chr(10), Chr(13)) then
        -- Пропустить символы конца строки
        while Get_Next_Char in (Chr(10), Chr(13))
        loop
          Skip_Char;
        end loop;
      else
        -- Перенести текущий указатель на конец буфера
        Finished;
      end if;
    end Skip_Line_Comment;

    -- Пропустить комментарии, пробелы и другие "белые" символы
    Procedure Skip_Blanks_And_Comments
    is
      v_Ch  Varchar2(1);
    begin
      -- Пропустить пробелы и другие "белые" символы
      loop
        -- Извлекать из буфера очередной символ
        v_Ch := Next_Char;
        -- Выйти, если символ не является "белым"
        exit when v_Ch is NULL or v_Ch not in (' ', Chr(9), Chr(10), Chr(13));
      end loop;
      -- Если найден символ '/'
      if v_Ch = '/' then
        -- Исследовать следующий символ
        v_Ch := Get_Next_Char;
        -- Если это комментарий, то пропустить
        if v_Ch = '/' then
          Skip_Line_Comment;
          Skip_Blanks_And_Comments;
        elsif v_Ch = '*' then
          Skip_Block_Comment;
          Skip_Blanks_And_Comments;
        end if;
      end if;
    end Skip_Blanks_And_Comments;

    -- Извлекать очередную лексему
    Procedure Get_Token
    is
    begin
      -- Извлекать очереднуой символ
      v_Token := Next_Char;
      -- Если получен "белый" символ или символ комментария
      if v_Token in (' ', Chr(9), Chr(10), Chr(13), '/') then
        -- Подать текущий символ обратно во вход
        Put_Char_Back;
        -- Пропустить комментарии, пробелы и другие "белые" символы
        Skip_Blanks_And_Comments;
        -- Извлекать из буфера текущий символ
        v_Token := SubStr(i_JSON(v_Page), v_Index, 1);
      end if;
      --
      -- Сохранить первый символ и позицию лексемы
      v_Token_Char  := v_Token;
      v_Token_Page  := v_Page;
      v_Token_Index := v_Index;
      --
      -- Разбирать и проверить лексему
      if v_Token is NULL then
        -- Конец буфера
        v_Token := 'F';
      elsif v_Token = '"' or v_Token = '''' then
        v_Token := 'S';
      elsif (v_Token >= '0' and v_Token <= '9') or v_Token in ('.', '+', '-') then
        v_Token := 'N';
      elsif (v_Token >= 'A' and v_Token <= 'Z') or (v_Token >= 'a' and v_Token <= 'z') or v_Token = '_' then
        v_Token := 'I';
      elsif v_Token not in (',', ':', '{', '}', '[', ']') then
        Syntax_Error;
      end if;
    end Get_Token;

    -- Проверить, достигнут ли конец блока
    Function Is_Block_End (i_Close_Char Varchar2) Return Boolean
    is
    begin
      -- Извлекать очередную лексему
      Get_Token;
      -- Разбирать и проверить лексему
      if v_Token = ',' then
        return False;
      elsif v_Token = i_Close_Char then
        return True;
      else
        Syntax_Error;
      end if;
    end Is_Block_End;

    -- Удостовериться, что очередной символ является ожидаемым символом
    Procedure Check_Symbol (i_Sym Varchar2)
    is
    begin
      -- Извлекать очередную лексему
      Get_Token;
      -- Разбирать и проверить лексему
      if v_Token != i_Sym then
        Syntax_Error;
      end if;
    end Check_Symbol;

    -- Синтаксическая проверка значения
    Procedure Check_Ident (i_Is_Value Boolean)
    is
      P      Simple_Integer := v_Token_Page;
      I      Simple_Integer := v_Token_Index;
      v_Ch   Varchar2(1);
      v_Name Varchar2(32767);
    begin
      -- Пропустить пробелы и другие "белые" символы
      loop
        -- Извлекать из буфера очередной символ
        v_Ch := Next_Char;
        -- Выйти, если символ не является "белым"
        exit when v_Ch is NULL;
        --
        exit when
          not ((v_Ch >= '0' and v_Ch <= '9') or (v_Ch >= 'A' and v_Ch <= 'Z') or
               (v_Ch >= 'a' and v_Ch <= 'z') or (v_Ch = '_'));
      end loop;
      -- Подать последний символ обратно во вход
      Put_Char_Back;
      --
      v_Name := Get_String(P, I, v_Page, v_Index);
      --
      if v_Name in ('true', 'false', 'null') then
        if not i_Is_Value then
          Syntax_Error;
        end if;
      elsif i_Is_Value then
        Syntax_Error;
      end if;
    end Check_Ident;

    -- Синтаксическая проверка значения
    Procedure Check_Number
    is
      v_Ch  Varchar2(1) := v_Token;
      v_Dot Boolean     := (v_Ch = '.');
    begin
      -- Если лексема является знаком "+" или "-"
      if v_Ch in ('.', '+', '-') then
        -- Игнорировать знак "+/-/."
        v_Ch := Next_Char;
        --
        if v_Dot and not (v_Ch >= '0' and v_Ch <= '9') then
          Syntax_Error;
        end if;
        -- Игнорировать пробелы
        while v_Ch in (' ', Chr(9))
        loop
          v_Ch := Next_Char;
        end loop;
        -- Подать последний символ обратно во вход
        Put_Char_Back;
      end if;
      -- Цикл для поиска конца цифрового значения
      loop
        -- Извлекать следующий символ
        v_Ch := Next_Char;
        --
        if v_Ch >= '0' and v_Ch <= '9' then
          -- Цифровой символ
          continue;
        elsif v_Ch = '.' then
          -- Плавающая точка
          if v_Dot then
            -- Повторная плавающая точка
            Syntax_Error;
          else
            v_Dot := True;
            continue;
          end if;
        end if;
        -- Конец цифры
        exit;
      end loop;
      -- Подать последний символ обратно во вход
      Put_Char_Back;
    end Check_Number;

    -- Синтаксическая проверка строки
    Procedure Check_String (i_Quote Varchar2)
    is
    begin
      -- Цикл для игнорирования парных кавычек
      loop
        -- Найти закрывающиеся кавычку
        if Find_Str(i_Quote) then
          --
          if Get_Next_Char = i_Quote then
            -- Игнорировать парные кавычки одинакового с внешними кавычками типа
            Skip_Char;
            continue;
          elsif Get_Prev_Char != '\' then   -- Игнорировать Escape-пару символов для кавычки
            -- Найден конец строки
            exit;
          end if;
        else
          -- Пропущена закрывающая кавычка!
          Syntax_Error;
        end if;
      end loop;
    end Check_String;

    -- Синтаксическая проверка значения
    Procedure Check_Value
    is
    begin
      -- Извлекать очередную лексему
      Get_Token;
      -- Разбирать и проверить лексему
      case v_Token
        when 'S' then Check_String(v_Token_Char);
        when 'N' then Check_Number;
        when 'I' then Check_Ident(True);
        when '{' then Check_Object;
        when '[' then Check_Array;
        else Syntax_Error;
      end case;
    end Check_Value;

    -- Синтаксическая проверка значения
    Procedure Check_Key_Value
    is
    begin
      -- Извлекать очередную лексему
      Get_Token;
      -- Разбирать и проверить лексему
      case v_Token
        when 'S' then Check_String(v_Token_Char);
        when 'I' then Check_Ident(False);
        else Syntax_Error;
      end case;
      -- Удостовериться, что очередной символ является символом ":"
      Check_Symbol(':');
      -- Синтаксическая проверка значения
      Check_Value;
    end Check_Key_Value;

    -- Синтаксическая проверка блока списка JSON
    Procedure Check_Array
    is
    begin
      -- Извлекать очередную лексему
      Get_Token;
      -- Разбирать и проверить лексему
      if v_Token = ']' then
        return;
      end if;
      -- Подать последний символ обратно во вход
      Put_Char_Back;
      -- Проверить все элементы списка
      loop
        -- Синтаксическая проверка значения
        Check_Value;
        -- Выйти из цикла, если достигнут конец списка
        exit when Is_Block_End(']');
      end loop;
    end Check_Array;

    -- Синтаксическая проверка блока объекта JSON
    Procedure Check_Object
    is
    begin
      -- Извлекать очередную лексему
      Get_Token;
      -- Разбирать и проверить лексему
      if v_Token = '}' then
        return;
      end if;
      -- Подать последний символ обратно во вход
      Put_Char_Back;
      -- Проверить все элементы объекта
      loop
        -- Синтаксическая проверка пары ключ-значение
        Check_Key_Value;
        -- Выйти из цикла, если достигнут конец списка
        exit when Is_Block_End('}');
      end loop;
    end Check_Object;

  begin
    -- Генерировать исключение, если буфер не инициализирован
    if i_JSON is NULL or i_JSON.Count = 0 then
      Raise_Application_Error(-20000, 'Не задана JSON-строка!');
    end if;
    --
    v_Page_Count := i_JSON.Count;
    v_Page       := Get_Next_Page(0);
    --
    if v_Page > 0 then
      -- Установить размер текущей страницы буфера
      v_Buf_Size := Length(i_JSON(v_Page));
    else
      -- Буфер пуст - генерировать исключение
      Raise_Application_Error(-20000, 'Задана пустая строка вместо JSON-строки!');
    end if;
    --
    -- Синтаксическая проверка объекта заданного типа
    if i_Type = 'O' then
      -- Удостовериться, что очередная лексема является символом "{"
      Check_Symbol('{');
      -- Проверить тело объекта JSON
      Check_Object;
    elsif i_Type = 'L' then
      -- Удостовериться, что очередная лексема является символом "["
      Check_Symbol('[');
      -- Проверить тело списка (массива) JSON
      Check_Array;
    else
      -- Буфер пуст - генерировать исключение
      Raise_Application_Error(-20000, 'Некорректный вызов внутреннего метода!');
      --
      Self.Op_NULL;    -- Сделаем компилятор довольным
    end if;
    -- Генерировать исключение, если не достигнут конец буфера
    if v_Page < v_Page_Count or v_Index < v_Buf_Size then
      -- Не достигнут конец буфера - генерировать исключение
      Raise_Application_Error(-20000, 'Символы после завершения JSON-строки недопустимы!');
    end if;
  end "_Check_Syntax ";
*/


  -- Проверить, закрыть ли JSON-строка
  -- Запрещается добавление новых элементов в закрытую строку
  final member function Is_Closed Return Boolean
  is
  begin
    -- Для закрытой строки текущий урвен равняется "0"
    return (Self."Level " <= 0);
  end Is_Closed;

  -- Проверить, открыть ли JSON-строка для добавления новых элементов
  final member function Is_Open Return Boolean
  is
  begin
    -- Для открытой строки текущий урвен больше "0"
    return (Self."Level " > 0);
  end Is_Open;

  -- Удостовериться, JSON-строка закрыта
  -- Запрещается извлечение содержимого буфера при не закрытой строке
  -- Из-за критичности на скорость допускается дублирование кода других методов
  final member procedure Check_Closed (Self in JSON_String_T)
  is
  begin
    -- Если строка не закрыта
    if Self."Level " > 0 then  -- Специально дублирован код метода Is_Open
      Self.Error(11, 'JSON-строка еще не закрыта!');  -- Строка не закрыта
    elsif Self."Buf " is NULL then
      Self.Error(12, 'JSON-строка пуста!');           -- Строка не может быть пустым
    end if;
  end Check_Closed;

  -- Удостовериться, JSON-строка открыта для добавления новых элементов
  -- Запрещается добавление новых элементов в закрытую строку
  -- Из-за критичности на скорость допускается дублирование кода других методов
  final member procedure Check_Open (Self in JSON_String_T)
  is
  begin
    -- Для открытой строки текущий урвен больше "0"
    if Self."Level " <= 0 then  -- Специально дублирован код метода Is_Closed
      Self.Error(13, 'JSON-строка уже закрыта!');
    end if;
  end Check_Open;

  -- Удостовериться, что заданный тип блока данных соответствует заданному типу блока
  -- Из-за критичности на скорость допускается дублирование кода других методов
  final member procedure Check_Level (
    Self in JSON_String_T,
    i_Level_Type  Varchar2,
    i_Op_Type     Varchar2
  )
  is
  begin
    -- Проверить тип и возможность закрытия уровня
    if Self."Level " <= 0 then  -- Специально дублирован код метода Is_Closed
      Check_Open();             -- Для генерации ошибки используем метод Check_Open
    elsif SubStr(Self."Levels ", Self."Level ", 1) != i_Level_Type then
      case i_Op_Type
        when 'C' then
          Self.Error (6, 'попытка закрытия блока несоответствующего типа');
        when 'O' then
          Self.Error (7, 'попытка вставки пары артибут-значение/объект, когда ожидается элемент списка');
        when 'L' then
          Self.Error (8, 'попытка вставки элемента списка, когда ожидается пара артибут-значение/объект');
        else
          Self.Error (9, 'Синтаксическая ошибка!');
      end case;
    end if;
  end Check_Level;


  -- Удостовериться, что заданная строка содержит синтаксически корректное
  -- описание объекта JSON
  final member Procedure Check_Syntax_Object (
    Self in JSON_String_T,
    i_JSON  Varchar2
  )
  is
  begin
    -- Вызвать метод синтаксической проверки
    Self."_Check_Syntax "(Array_Varchar2(i_JSON), 'O');
  end Check_Syntax_Object;

  -- Удостовериться, что заданная коллекция строк содержит синтаксически корректное
  -- описание объекта JSON
  final member Procedure Check_Syntax_Object (
    Self in JSON_String_T,
    i_JSON  Array_Varchar2
  )
  is
  begin
    -- Вызвать метод синтаксической проверки
    Self."_Check_Syntax "(i_JSON, 'O');
  end Check_Syntax_Object;

  -- Удостовериться, что заданная строка содержит синтаксически корректное
  -- описание списка (массива) JSON
  final member Procedure Check_Syntax_Array (
    Self in JSON_String_T,
    i_JSON  Varchar2
  )
  is
  begin
    -- Вызвать метод синтаксической проверки
    Self."_Check_Syntax "(Array_Varchar2(i_JSON), 'L');
  end Check_Syntax_Array;

  -- Удостовериться, что заданная коллекция строк содержит синтаксически корректное
  -- описание списка (массива) JSON
  final member Procedure Check_Syntax_Array (
    Self in JSON_String_T,
    i_JSON  Array_Varchar2
  )
  is
  begin
    -- Вызвать метод синтаксической проверки
    Self."_Check_Syntax "(i_JSON, 'L');
  end Check_Syntax_Array;


  -- Закрыть JSON-строку
  -- В отличие от метода Close_JSON, который закрывает текущий JSON-объект,
  -- попытается закрыть основной блок JSON-строки
  -- При обнаружении незакрытого вложенного блока любого типа генерирует исключение
  final member procedure Close (Self in out nocopy JSON_String_T)
  is
  begin
    --
    if Self."Level " > 1 then
      Self.Error(20, 'Синтаксическая ошибка: попытка закрытия незавершенного объекта JSON!');
    end if;
    -- Закрыть JSON-строку
    Self.Close_JSON();
  end Close;

  -- Открыть ранее закрытыю JSON-строку для изменений
  -- Если JSON-строка не закрыто, то генерирует исключение
  final member procedure Open (Self in out nocopy JSON_String_T)
  is
    v_Buf_Len  PLS_Integer := Length(Self."Buf ");
  begin
    --
    if Self."Level " > 0 then
      Self.Error(21, 'Попытка открытия не закрытого объекта JSON!');
    elsif Self."Buf " is NULL or SubStr(Self."Buf ", v_Buf_Len, 1) != '}' then
      Self.Error(22, 'Синтаксическая ошибка: JSON-строка должна заканчиваться символом "}"!');
    end if;
    -- Открыть JSON-строку для изменений
    Self."Level "  := 1;                   -- Уровень глубины текущего блока данных
    Self."Levels " := 'O';                 -- Типы блоков данных вложенных уровней
    --
    Self."Buf "    := SubStr(Self."Buf ", 1, v_Buf_Len - 1);
    Self."Length " := Self."Length " - 1;
    --
    if Self."Length " <= 1 then
      Self."Is_Empty " := 'Y';            -- Текущий уровень еще пуст
    else
      Self."Is_Empty " := 'N';            -- Текущий уровень не пуст
    end if;
  end Open;

  -- Открыть новый объект JSON с заданным именем
  final member procedure Open_JSON (
    Self in out nocopy JSON_String_T,
    i_Name  Varchar2 := NULL
  )
  is
  begin
    -- Открыть новый объект JSON
    Self."_Open_New_Level "('{', 'O', i_Name);
  end Open_JSON;

  -- Закрыть текущий объект JSON
  final member procedure Close_JSON (Self in out nocopy JSON_String_T)
  is
  begin
    -- Закрыть текущий объект JSON
    Self."_Close_Cur_Level "('}', 'O');
  end Close_JSON;

  -- Открыть новый список значений с заданным именем
  final member procedure Open_Array (
    Self in out nocopy JSON_String_T,
    i_Name  Varchar2 := NULL
  )
  is
  begin
    -- Открыть новый объект JSON
    Self."_Open_New_Level "('[', 'L', i_Name);
  end Open_Array;

  -- Закрыть текущий объект JSON
  final member procedure Close_Array (Self in out nocopy JSON_String_T)
  is
  begin
    -- Закрыть текущий объект JSON
    Self."_Close_Cur_Level "(']', 'L');
  end Close_Array;

  -- Добавть пару ключ-значение стротного типа в текущий объект JSON
  final member procedure Put (
    Self in out nocopy JSON_String_T,
    i_Key    Varchar2,
    i_Value  Varchar2
  )
  is
  begin
    -- Добавить подготовленную пару ключ-значение в объект JSON
    Self."_Put_In_Object " (Self.Format(i_Key), Self.Format(i_Value));
  end Put;

  -- Добавть пару ключ-значение числового типа в текущий объект JSON
  final member procedure Put (
    Self in out nocopy JSON_String_T,
    i_Key    Varchar2,
    i_Value  Number,
    i_Fmt    Varchar2 := NULL
  )
  is
  begin
    -- Добавить подготовленную пару ключ-значение в объект JSON
    Self."_Put_In_Object " (Self.Format(i_Key), Self.Format(i_Value, i_Fmt));
  end Put;

  -- Добавть пару ключ-значение типа дата и время в текущий объект JSON
  final member procedure Put (
    Self in out nocopy JSON_String_T,
    i_Key    Varchar2,
    i_Value  Date,
    i_Fmt    Varchar2 := NULL
  )
  is
  begin
    -- Добавить подготовленную пару ключ-значение в объект JSON
    Self."_Put_In_Object " (Self.Format(i_Key), Self.Format(i_Value, i_Fmt));
  end Put;

  -- Добавть пару ключ-значение логического типа в текущий объект JSON
  final member procedure Put (
    Self in out nocopy JSON_String_T,
    i_Key    Varchar2,
    i_Value  Boolean
  )
  is
  begin
    -- Добавить подготовленную пару ключ-значение в объект JSON
    Self."_Put_In_Object " (Self.Format(i_Key), Self.Format(i_Value));
  end Put;

  -- Вставить длинную строку в текущий объект JSON в качестве значения ключа
  final member procedure Put (
    Self in out nocopy JSON_String_T,
    i_Key    Varchar2,
    i_Value  Long_String
  )
  is
  begin
    -- Вставить длинную строку в качестве строки
    Self."_Put_Long_String " ('O', i_Key, i_Value.To_String_Array());
  end Put;

  -- Вставить объект JSON в текущий объект JSON в качестве значения ключа
  final member procedure Put (
    Self in out nocopy JSON_String_T,
    i_Key    Varchar2,
    i_Value  JSON_String_T
  )
  is
  begin
    -- Удостовериться, что пара ключ-значение вставляется в JSON-объект
    Self.Check_Level('O', 'O');
    --
    -- Добавить объект JSON в конец буфера
    Self."_Append_JSON " (NVL(i_Key, 'Object'), i_Value);
  end Put;

  -- Вставить коллекцию строк в текущий объект JSON в качестве списка-значения ключа
  -- В параметре i_Types можно передавать типы значений элементов коллекции
  -- Если коллекция содержит больше элементов, чем длина параметра i_Types, то для
  -- оставшихся элементов тип будет как "s" (строка, пустые строки вставляются как
  -- "null"). Неверные значения типов значений также заменяются на "s".
  -- ВНИМАНИЕ! В данной процедуре корректность числовых значений не проверяется!
  -- Параметры:
  --    i_Values - Коллекция значений списка
  --    i_Types  - Коллекция типов значений списка, где:
  --               S - строка, пустые строки вставляются как пустая строка ("")
  --               s - строка, пустые строки вставляются как нуль ("null")
  --               N - число, NULL-значения вставляются как пустая строка ("")
  --               n - число, NULL-значения вставляются как нуль ("null")
  --               B - логическое значение (true, false),
  --                   NULL-значения вставляются как пустая строка (""),
  --                   некорректные значения вставляются как ("false")
  --               b - логическое значение,
  --                   NULL-значения вставляются как нуль ("null"),
  --                   некорректные значения вставляются как строка
  --               Z - Вставить "null", соответствующее значение в коллекции игнорируется
  --               z - Вставить "null", если соответствующее значение в коллекции
  --                   не является "null" или NULL, то вставляется как строка
  --    i_Index  - Индекс элемента коллекции, с которой должна начинаться вставка
  --    i_Count  - Количество элементов для вставки (NULL - все элементы, начиная
  --               с позиции i_Index)
  final member procedure Put (
    Self in out nocopy JSON_String_T,
    i_Key     Varchar2,
    i_Values  Array_Varchar2,
    i_Types   Varchar2       := NULL,
    i_Index   Simple_Integer := 1,
    i_Count   PLS_Integer    := NULL
  )
  is
  begin
    -- Удостовериться, что пара ключ-значение вставляется в JSON-объект
    Self.Check_Level('O', 'O');
    --
    -- Вызвать процедуру быстрой вставки списка значений в буфер
    Self."_Put_Array "(i_Key, i_Values, i_Types, i_Index, i_Count);
  end Put;

  -- Добавть значение нуль по ключу в текущий объект JSON
  final member procedure Put_Null (
    Self in out nocopy JSON_String_T,
    i_Key  Varchar2
  )
  is
  begin
    -- Добавить подготовленную пару ключ-значение в объект JSON
    Self."_Put_In_Object " (Self.Format(i_Key), 'null');
  end Put_Null;

  -- Вставить коллекцию строк в текущий объект JSON в качестве единой строки
  final member procedure Put_As_String (
    Self in out nocopy JSON_String_T,
    i_Key    Varchar2,
    i_Value  Array_Varchar2
  )
  is
  begin
    -- Вставить коллекцию в качестве строки
    Self."_Put_Long_String " ('O', i_Key, i_Value);
  end Put_As_String;

  -- Вставить объект JSON в текущий объект JSON в качестве значения ключа
  final member procedure Put_As_Array (
    Self in out nocopy JSON_String_T,
    i_Key    Varchar2,
    i_Value  Varchar2,
    i_Check  Boolean := True
  )
  is
  begin
    -- Выхвать перегруженный метод для коллекции строк
    Self.Put_As_Array (i_Key, Array_Varchar2(i_Value), i_Check);
  end Put_As_Array;

  -- Вставить тело списка JSON в текущий объект JSON в качестве значения ключа
  final member procedure Put_As_Array (
    Self in out nocopy JSON_String_T,
    i_Key    Varchar2,
    i_Value  Array_Varchar2,
    i_Check  Boolean       := True
  )
  is
  begin
    -- При необходимости выполнить синтаксическую проверку
    if i_Check then
      Self.Check_Syntax_Array(i_Value);
    end if;
    -- Вставить готовое тело списка JSON
    Self."_Put_Object_Body " (i_Key, i_Value, 'O');
  end Put_As_Array;

  -- Вставить объект JSON в текущий объект JSON в качестве значения ключа
  final member procedure Put_As_JSON (
    Self in out nocopy JSON_String_T,
    i_Key    Varchar2,
    i_Value  Varchar2,
    i_Check  Boolean := True
  )
  is
  begin
    -- Выхвать перегруженный метод для коллекции строк
    Self.Put_As_JSON (i_Key, Array_Varchar2(i_Value), i_Check);
  end Put_As_JSON;

  -- Вставить объект JSON в текущий объект JSON в качестве значения ключа
  final member procedure Put_As_JSON (
    Self in out nocopy JSON_String_T,
    i_Key    Varchar2,
    i_Value  Array_Varchar2,
    i_Check  Boolean       := True
  )
  is
  begin
    -- При необходимости выполнить синтаксическую проверку
    if i_Check then
      Self.Check_Syntax_Object(i_Value);
    end if;
    -- Вставить готовое тело объекта JSON
    Self."_Put_Object_Body " (i_Key, i_Value, 'O');
  end Put_As_JSON;


  -- Добавть символьное значение в текущий список
  final member procedure Add_Elem (
    Self in out nocopy JSON_String_T,
    i_Value  Varchar2
  )
  is
  begin
    -- Добавить значение в текущий список
    Self."_Put_In_List " (Self.Format(i_Value));
  end Add_Elem;

  -- Добавть числовое значение в текущий список
  final member procedure Add_Elem (
    Self in out nocopy JSON_String_T,
    i_Value  Number,
    i_Fmt    Varchar2 := NULL
  )
  is
  begin
    -- Добавить значение в текущий список
    Self."_Put_In_List " (Self.Format(i_Value, i_Fmt));
  end Add_Elem;

  -- Добавть значение типа дата и время в текущий список
  final member procedure Add_Elem (
    Self in out nocopy JSON_String_T,
    i_Value  Date,
    i_Fmt    Varchar2 := NULL
  )
  is
  begin
    -- Добавить значение в текущий список
    Self."_Put_In_List " (Self.Format(i_Value, i_Fmt));
  end Add_Elem;

  -- Добавить логическое значение в текущий список
  final member procedure Add_Elem (
    Self in out nocopy JSON_String_T,
    i_Value  Boolean
  )
  is
  begin
    -- Добавить логическое значение в список
    Self."_Put_In_List " (Self.Format(i_Value));
  end Add_Elem;

  -- Вставить длинную строку в текущий объект JSON в качестве строки
  final member procedure Add_Elem (
    Self in out nocopy JSON_String_T,
    i_Value  Long_String
  )
  is
  begin
    -- Вставить длинную строку в качестве строки
    Self."_Put_Long_String " ('L', NULL, i_Value.To_String_Array());
  end Add_Elem;

  -- Вставить объект JSON в текущий список
  final member procedure Add_Elem (
    Self in out nocopy JSON_String_T,
    i_Value  JSON_String_T
  )
  is
  begin
    -- Удостовериться, что значение вставляется в список
    Self.Check_Level('L', 'L');
    --
    -- Добавить объект JSON в конец буфера
    Self."_Append_JSON " (NULL, i_Value);
  end Add_Elem;

  -- Вставить коллекцию строк в текущий список в качестве вложенного списка значений
  -- В параметре i_Types можно передавать типы значений элементов коллекции
  -- Если коллекция содержит больше элементов, чем длина параметра i_Types, то для
  -- оставшихся элементов тип будет как "s" (строка, пустые строки вставляются как
  -- "null"). Неверные значения типов значений также заменяются на "s".
  -- ВНИМАНИЕ! В данной процедуре корректность числовых значений не проверяется!
  -- Параметры:
  --    i_Values - Коллекция значений списка
  --    i_Types  - Коллекция типов значений списка, где:
  --               S - строка, пустые строки вставляются как пустая строка ("")
  --               s - строка, пустые строки вставляются как нуль ("null")
  --               N - число, NULL-значения вставляются как пустая строка ("")
  --               n - число, NULL-значения вставляются как нуль ("null")
  --               B - логическое значение (true, false),
  --                   NULL-значения вставляются как пустая строка (""),
  --                   некорректные значения вставляются как ("false")
  --               b - логическое значение,
  --                   NULL-значения вставляются как нуль ("null"),
  --                   некорректные значения вставляются как строка
  --               Z - Вставить "null", соответствующее значение в коллекции игнорируется
  --               z - Вставить "null", если соответствующее значение в коллекции
  --                   не является "null" или NULL, то вставляется как строка
  --    i_Index  - Индекс элемента коллекции, с которой должна начинаться вставка
  --    i_Count  - Количество элементов для вставки (NULL - все элементы, начиная
  --               с позиции i_Index)
  final member procedure Add_Elem (
    Self in out nocopy JSON_String_T,
    i_Values  Array_Varchar2,
    i_Types   Varchar2       := NULL,
    i_Index   Simple_Integer := 1,
    i_Count   PLS_Integer    := NULL
  )
  is
  begin
    -- Удостовериться, что значение вставляется в список
    Self.Check_Level('L', 'L');
    --
    -- Добавить коллекцию в виде вложенного списка значений в текущий список
    Self."_Put_Array "(NULL, i_Values, i_Types, i_Index, i_Count);
  end Add_Elem;

  -- Добавить значение "null" в текущий список
  final member procedure Add_Null (Self in out nocopy JSON_String_T)
  is
  begin
    -- Добавить "null" в список
    Self."_Put_In_List " ('null');
  end Add_Null;

  -- Вставить коллекцию строк в текущий объект JSON в качестве единой строки
  final member procedure Add_As_String (
    Self in out nocopy JSON_String_T,
    i_Value  Array_Varchar2
  )
  is
  begin
    -- Вставить коллекцию в качестве строки
    Self."_Put_Long_String " ('L', NULL, i_Value);
  end Add_As_String;

  -- Вставить коллекцию строк в текущий список в виде вложенного списка
  final member procedure Add_As_Array (
    Self in out nocopy JSON_String_T,
    i_Value  Varchar2,
    i_Check  Boolean := True
  )
  is
  begin
    -- Вызвать перегруженный метод для коллекции строк
    Self.Add_As_Array (Array_Varchar2(i_Value), i_Check);
  end Add_As_Array;

  -- Вставить коллекцию строк в текущий список в виде вложенного списка
  final member procedure Add_As_Array (
    Self in out nocopy JSON_String_T,
    i_Value  Array_Varchar2,
    i_Check  Boolean       := True
  )
  is
  begin
    -- При необходимости выполнить синтаксическую проверку
    if i_Check then
      Self.Check_Syntax_Array(i_Value);
    end if;
    -- Вставить готовое тело списка JSON
    Self."_Put_Object_Body " (NULL, i_Value, 'L');
  end Add_As_Array;

  -- Вставить коллекцию строк в текущий список в виде кложенного объекта JSON
  final member procedure Add_As_JSON (
    Self in out nocopy JSON_String_T,
    i_Value  Varchar2,
    i_Check  Boolean := True
  )
  is
  begin
    -- Вызвать перегруженный метод для коллекции строк
    Self.Add_As_JSON (Array_Varchar2(i_Value), i_Check);
  end Add_As_JSON;

  -- Вставить коллекцию строк в текущий список в виде кложенного объекта JSON
  final member procedure Add_As_JSON (
    Self in out nocopy JSON_String_T,
    i_Value  Array_Varchar2,
    i_Check  Boolean       := True
  )
  is
  begin
    -- При необходимости выполнить синтаксическую проверку
    if i_Check then
      Self.Check_Syntax_Object(i_Value);
    end if;
    -- Вставить готовое тело объекта JSON
    Self."_Put_Object_Body " (NULL, i_Value, 'L');
  end Add_As_JSON;


  -- Присоединить заданную строку JSON к данному строку JSON
  -- Присоединяемая JSON-строка должна быть закрыта
  -- Присоединение другого объекта JSON допустимо только на уровне основного
  -- объекта JSON.
  -- При попытке выполнения процедуры присоединения во вложенных уровнях
  -- генерируетя исключение
  -- После присоединения закроет данную JSON-строку
  final member procedure Merge (
    Self in out nocopy JSON_String_T,
    i_JSON  JSON_String_T
  )
  is
    v_Count  PLS_Integer;
    v_Comma  Varchar2(1);
  begin
    --
    if (i_JSON is NULL or i_JSON."Raw_Data " is NULL or
        i_JSON."Raw_Data ".Count = 0) and i_JSON."Buf " = '{}' then
      return;
    elsif i_JSON."Level " > 0 then
      Self.Error(22, 'Попытка присоединения незакрытого объекта JSON!');
    elsif Self."Level " > 1 then
      Self.Error(23, 'Присоединение другого объекта JSON недопустимо во вложенных уровнях!');
    elsif Self."Level " <= 0 then
      Self.Open();
    end if;
    --
    if Self."Is_Empty " = 'N' then
      v_Comma := ',';
    end if;
    --
    v_Count := i_JSON.Get_Buf_Count();
    --
    if v_Count = 1 then
      -- Вставить единственный буфер присоединяемого объекта
      Self."_Append_Str " (v_Comma || SubStr(i_JSON."Buf ", 2));
    else
      -- Вставить первую страницу буфера присоединяемого объекта
      Self."_Append_Str " (v_Comma || SubStr(i_JSON."_Extract_String "(1), 2));
      --
      for I in 2..v_Count - 1
      loop
        -- Вставить страницу буфера присоединяемого объекта
        Self."_Append_Str " (i_JSON."_Extract_String "(I));
      end loop;
      -- Вставить основной буфер присоединяемого объекта
      Self."_Append_Str " (i_JSON."Buf ");
    end if;
    -- Отменить признак пустоты объекта
    Self."Is_Empty " := 'N';
    -- Закрыть данную JSON-строку
    Self.Close();
  end Merge;


  -- Возвращать значение в виде строки
  -- Если длина строки превышает 32К, то генерирует исключение
  final member function To_String Return Varchar2
  is
  begin
    -- Удостовериться, что строка закрыта
    Self.Check_Closed();
    -- Если расширенный буфер не пуст
    if Self."Raw_Data " is not NULL and Self."Raw_Data ".Count > 0 then
      -- Подстрока не помещается в буфер
      Error(99, 'Строка не помещается в буфере!');
    end if;
    -- Возвращать значение в виде строки
    return Self."Buf ";
  end To_String;

  -- Возвращать значение в виде коллекции данных в двоичном представлении
  final member function To_Raw_Array (i_Compress Varchar2 := NULL) Return Array_Raw
  is
    Result  Array_Raw := Array_Raw();
  begin
    -- Удостовериться, что строка закрыта
    Self.Check_Closed();
    --
    -- Вставить в буфер содержимое буфера (включая основной буфер)
    for I in 1..Self.Get_Buf_Count
    loop
      Result.Extend;
      Result(Result.Count) := Self."_Extract_Raw_Data "(I, i_Compress);
    end loop;
    -- Возвращать результат
    return Result;
  end To_Raw_Array;

  -- Возвращать значение в виде коллекции строк
  final member function To_String_Array Return Array_Varchar2
  is
    Result       Array_Varchar2 := Array_Varchar2();
    v_Buf_Count  PLS_Integer    := Self.Get_Buf_Count;
  begin
    -- Удостовериться, что строка закрыта
    Self.Check_Closed();
    --
    for I in 1..v_Buf_Count
    loop
      -- Добавить очередной блок в результат
      Result.Extend;
      if I = v_Buf_Count then
        Result(I) := Self."Buf ";
      else
        Result(I) := Self."_Extract_String "(I);
      end if;
    end loop;
    -- Возвращать результат
    return Result;
  end To_String_Array;

  -- Возвращать значение в виде коллекции строк с заданной максимальной длиной элемента
  -- Добавлен от 27.11.2020
  final member function To_String_Array (i_Elem_Length PLS_Integer) Return Array_Varchar2
  is
    Result       Array_Varchar2 := Array_Varchar2();
    v_Buf_Count  PLS_Integer    := Self.Get_Buf_Count;
    v_Index      PLS_Integer;
    v_Page       Varchar2(32767);
  begin
    -- Если задан слишком большой или некорректный размер элемента, то переадресовать
    -- вызов к перегруженной версии функции
    if i_Elem_Length < 1 or i_Elem_Length >= 32767 then
      -- Переадресовать вызов к перегруженной версии функции
      return Self.To_String_Array();
    end if;
    -- Удостовериться, что строка закрыта
    Self.Check_Closed();
    --
    for I in 1..v_Buf_Count
    loop
      --
      if I = v_Buf_Count then
        v_Page := Self."Buf ";
      else
        v_Page := Self."_Extract_String "(I);
      end if;
      --
      v_Index := 1;
      --
      while v_Index <= Length(v_Page)
      loop
        -- Добавить очередной блок в результат
        Result.Extend;
        Result(I) := SubStr(v_Page, v_Index, i_Elem_Length);
        -- Увеличить индекс текущей позиции
        v_Index := v_Index + i_Elem_Length;
      end loop;
    end loop;
    -- Возвращать результат
    return Result;
  end To_String_Array;

  -- Возвращать значение в виде объекта CLOB
  final member function To_CLob Return CLob
  is
    Result  CLob;
    v_Buf   Varchar2(32767);
  begin
    -- Удостовериться, что строка закрыта
    Self.Check_Closed();
    --
    -- Присвоить первую страницу буфера в результат
    Result := Self."_Extract_String "(1);
    --
    -- Возвращать значение в виде объекта CLOB
    for I in 2..Self.Get_Buf_Count
    loop
      -- Извлекать очередной блок буфера
      v_Buf := Self."_Extract_String "(I);
      -- Добавить страницу буфера в результат
      DBMS_Lob.WriteAppend(Result, LengthB(v_Buf), v_Buf);
    end loop;
    -- Возвращать значение в виде объекта CLOB
    return Result;
  end To_CLob;

  -- Возвращать значение в виде объекта BLOB
  final member function To_BLob Return BLob
  is
    Result  BLob;
    v_Buf   Raw(32767);
  begin
    -- Удостовериться, что строка закрыта
    Self.Check_Closed();
    --
    -- Присвоить первую страницу буфера в результат
    Result := Self."_Extract_Raw_Data "(1, 'N');
    --
    -- Возвращать значение в виде объекта CLOB
    for I in 2..Self.Get_Buf_Count
    loop
      -- Извлекать очередной блок буфера
      v_Buf := Self."_Extract_Raw_Data "(I, 'N');
      -- Добавить страницу буфера в результат
      DBMS_Lob.WriteAppend(Result, UTL_Raw.Length(v_Buf), v_Buf);
    end loop;
    -- Возвращать значение в виде объекта CLOB
    return Result;
  end To_BLob;


  -- Возвращать значение в виде коллекции строк для отладочных целей
  final member function Debug Return Array_Varchar2
  is
    Result  Array_Varchar2 := Array_Varchar2();
  begin
    for I in 1..Self.Get_Buf_Count
    loop
      -- Добавить очередной блок в результат
      Result.Extend;
      Result(I) := Self."_Extract_String "(I, True);
    end loop;
    -- Возвращать результат
    return Result;
  end Debug;



end;
/
