  MEMBER

  INCLUDE('tbstr.inc'), ONCE

  MAP
    MODULE('OLEAUTO API')
      SysAllocString(LONG psz),BSTR,PASCAL
      SysAllocStringLen(LONG psz,ULONG pChars),BSTR,PASCAL
      SysFreeString(BSTR bstrString),PASCAL
      SysStringByteLen(BSTR bstrString),ULONG,PASCAL  !- Returns the length (in bytes) of a BSTR.
      SysStringLen(BSTR bstrString),ULONG,PASCAL      !- Returns the length of a BSTR.
      SysReAllocString(*BSTR bstrString,LONG psz),BOOL,PASCAL,PROC
    END
  END

TSysString.Construct          PROCEDURE()
  CODE
  SELF.ptr = 0
  
TSysString.Destruct           PROCEDURE()
  CODE
  SELF.Free()
  
TSysString.Alloc              PROCEDURE(OLECHAR psz)
  CODE
  SELF.Free()
  IF LEN(psz)
    SELF.ptr = SysAllocString(ADDRESS(psz))
    SELF.bDontFree = FALSE
    RETURN SELF.ptr
  ELSE
    SELF.bDontFree = TRUE
    SELF.ptr = 0
  END
  RETURN SELF.ptr

TSysString.AllocLen           PROCEDURE(OLECHAR psz, UNSIGNED pcount)
  CODE
  SELF.Free()
  IF LEN(psz)
    SELF.ptr = SysAllocStringLen(ADDRESS(psz), pcount)
    SELF.bDontFree = FALSE
  ELSE
    SELF.ptr = 0
  END
  RETURN SELF.ptr

TSysString.Free               PROCEDURE()
  CODE
  IF SELF.ptr AND SELF.bDontFree = FALSE
    SysFreeString(SELF.ptr)
    SELF.ptr = 0
    SELF.bDontFree = FALSE
  END

TSysString.ByteLen            PROCEDURE()
  CODE
  RETURN SysStringByteLen(SELF.ptr)
  
TSysString.Len                PROCEDURE()
  CODE
  RETURN SysStringLen(SELF.ptr)

TSysString.ReAlloc            PROCEDURE(OLECHAR psz)
  CODE
  RETURN SysReAllocString(SELF.ptr, ADDRESS(psz))
  
TSysString.GetPtr             PROCEDURE()
  CODE
  RETURN SELF.ptr
  
TSysString.Assign             PROCEDURE(BSTR pBstr)
  CODE
  SELF.Free()
  SELF.ptr = pBstr
  SELF.bDontFree = TRUE
  
TSysString.WideStringRef      PROCEDURE()
bytes                           ULONG, AUTO
wstr                            &OLECHAR
  CODE
  IF SELF.ptr
    bytes = SELF.ByteLen()
    IF bytes
      wstr &= (SELF.ptr) &':'& bytes
    END
  END
  RETURN wstr
    
TSysString.DontFree           PROCEDURE(BOOL pVal)
  CODE
  SELF.bDontFree = pVal