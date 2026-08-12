create or replace type "HASHTABLE" as object
(
-- Author  : ARTIKALI
-- Created : 29.03.2010 19:53:56
-- Purpose :

-- Attributes
  Buckets Hash_Bucket_Array,

-- Member functions and procedures
  constructor Function Hashtable return self as result,

  member Procedure Put
  (
    Key   varchar2,
    Entry Hash_Entry
  ),
  member Function Get(Key varchar2) return Hash_Entry,
  member Procedure Remove(Key varchar2),
  member Function Has(Key varchar2) return boolean,
  member Function count return pls_integer,

------------------------------------------------------------------------------------------------------
  member Procedure Put
  (
    Key   varchar2,
    value varchar2
  ),
  member Procedure Put
  (
    Key   varchar2,
    value number
  ),
  member Procedure Put
  (
    Key   varchar2,
    value date
  ),
  member Procedure Put
  (
    Key   varchar2,
    value Array_Varchar2
  ),
  member Procedure Put
  (
    Key   varchar2,
    value Array_Number
  ),
  member Procedure Put
  (
    Key   varchar2,
    value Array_Date
  ),

------------------------------------------------------------------------------------------------------
  member Function Get_Varchar2(Key varchar2) return varchar2,
  member Function Get_Number
  (
    Key    varchar2,
    Format varchar2 := null
  ) return number,
  member Function Get_Date
  (
    Key    varchar2,
    Format varchar2 := null
  ) return date,
  member Function Get_Array_Varchar2(Key varchar2) return Array_Varchar2,
  member Function Get_Array_Number
  (
    Key    varchar2,
    Format varchar2 := null
  ) return Array_Number,
  member Function Get_Array_Date
  (
    Key    varchar2,
    Format varchar2 := null
  ) return Array_Date,

------------------------------------------------------------------------------------------------------
  member Function Get_Optional_Varchar2(Key varchar2) return varchar2,
  member Function Get_Optional_Number
  (
    Key    varchar2,
    Format varchar2 := null
  ) return number,
  member Function Get_Optional_Date
  (
    Key    varchar2,
    Format varchar2 := null
  ) return date,
  member Function Get_Optional_Array_Varchar2(Key varchar2) return Array_Varchar2,
  member Function Get_Optional_Array_Number
  (
    Key    varchar2,
    Format varchar2 := null
  ) return Array_Number,
  member Function Get_Optional_Array_Date
  (
    Key    varchar2,
    Format varchar2 := null
  ) return Array_Date,

------------------------------------------------------------------------------------------------------
  member Function Get_Bucket return Hash_Bucket,

  member Procedure Print_To_Htp(self in Hashtable),

  static Function hash(Key varchar2) return pls_integer

)
/
ALTER TYPE HASHTABLE
  ADD MEMBER FUNCTION Json RETURN VARCHAR2 CASCADE
/
