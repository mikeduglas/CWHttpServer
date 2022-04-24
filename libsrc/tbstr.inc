!* BSTR wrapper
!* mikeduglas 2021

  OMIT('_COMDefinitions_',_COMDefinitions_)
BSTR                          EQUATE(LONG)
  !'_COMDefinitions_'

OLECHAR                       EQUATE(STRING)    !- wide string

TSysString                    CLASS, TYPE, MODULE('tbstr.clw'), LINK('tbstr.clw')
ptr                             BSTR, PRIVATE
bDontFree                       BOOL, PRIVATE

Construct                       PROCEDURE()
Destruct                        PROCEDURE()
Alloc                           PROCEDURE(OLECHAR psz), BSTR, PROC
AllocLen                        PROCEDURE(OLECHAR psz, UNSIGNED pcount), BSTR, PROC
Free                            PROCEDURE()
ByteLen                         PROCEDURE(), ULONG      !- Returns the length (in bytes) of a BSTR.
Len                             PROCEDURE(), ULONG      !- Returns the length of a BSTR.
ReAlloc                         PROCEDURE(OLECHAR psz), BOOL, PROC
GetPtr                          PROCEDURE(), BSTR
Assign                          PROCEDURE(BSTR pBstr)
WideStringRef                   PROCEDURE(), *OLECHAR
DontFree                        PROCEDURE(BOOL pVal)
                              END
