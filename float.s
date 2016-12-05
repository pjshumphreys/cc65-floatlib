
;---------------------------------------------------------------------------------------------

__basicon:
        sei
        ldx #$37
        stx $01
        rts

__basicoff:
        ldx #$36
        stx $01
        cli
        rts

        .importzp sp

;
; pop y/a from stack. This function will run directly into incsp2x
;
; routine saves 2 bytes each call, is 27 bytes long
; => usage pays off as a size improvement if called atleast 14 times,
; else 'bloats' the code by 27 bytes ;=)
;
        .export         popya

popya:
        ldy     #1
        lda (sp),y    ; get hi byte
        tax         ; into x
        dey
        lda (sp),y    ; get lo byte
        ; put parameters in right order for kernal routines
        tay
        txa

;
; routines for inc/dec'ing sp
;
; do this by hand, cause it gets used a lot
        .export         incsp2x

incsp2x:
        ldx sp              ; 3
        inx                 ; 2
        beq @L1             ; 2
        inx                 ; 2
        beq @L2             ; 2
        stx sp              ; 3
        rts
@L1:
        inx                 ; 2
@L2:
        stx sp              ; 3
        inc sp+1            ; 5
        rts

;---------------------------------------------------------------------------------------------

  .export   __ftostr,__strtof,__ftoi
  .export   __fcmp,__ftestsgn
  .export   __ctof,__utof,__itof,__stof
  .export   __fadd,__fsub,__fmul,__fdiv,__fpow
  .export   __fand,__for,__fnot,__fneg
  .export   __fabs, __fatn, __fcos, __fexp, __fint, __flog,__frnd
  .export   __fsgn, __fsin, __fsqr, __ftan,__fnot,__fround
  .export   __fpoly1,__fpoly2
  .export   __fatan2

  .import   popa,popax,pushax,pusha
  .importzp ptr1

  .include  "float.inc"

;---------------------------------------------------------------------------------------------
; load float from memory to fac and/or arg and back for further processing
; we cant use the routines from basic for this task since source address
; may be located in the same bank as basic rom.
;---------------------------------------------------------------------------------------------

  .import ldeaxysp, incsp4

___float_float_to_fac:
        ldy #$03
        jsr ldeaxysp
        sta $63 ; mantissa
        stx $62 ; mantissa

        ldy sreg
        sty $61 ; exp

        ldy sreg+1
        sty $66 ; sign

        ldx #$00
        stx $64 ; mantissa
        stx $65 ; mantissa
        stx $70

.if 1=0
        ldx #0
@l:
        lda $61,x
        sta $0400+(0*40),x
        inx
        cpx #6
        bne @l
.endif

        jmp incsp4

__float_float_to_fac:
        sta ptr1
        stx ptr1+1
        ldy #$00

        lda (ptr1),y
        sta $61
        iny

        lda (ptr1),y
        sta $62
        iny

        lda (ptr1),y
        sta $63
        iny

        lda (ptr1),y
        sta $64
        iny

        lda (ptr1),y
        sta $65
        iny

        lda (ptr1),y
        sta $66
        ldx #$00
        stx $70

        rts

; get two floats, to FAC and ARG

___float_float_to_fac_arg:
        jsr ___float_float_to_fac    ; also pops pointer to float

___float_float_to_arg:
        ldy #$03
        jsr ldeaxysp
        sta $6b ; mantissa
        stx $6a ; mantissa

        ldy sreg
        sty $69 ; exp
        ldx #$00
        stx $6c ; mantissa
        stx $6d ; mantissa

        lda sreg+1
        sta $6e ; sign
        eor $66 ; sign FAC
        sta $6f

.if 1=0
        ldx #0
@l:
        lda $69,x
        sta $0400+(1*40),x
        inx
        cpx #6
        bne @l
.endif

        jmp incsp4

__float_float_to_arg:
        sta ptr1
        stx ptr1+1

        ldy #$00
        lda (ptr1),y
        sta $69
        iny

        lda (ptr1),y
        sta $6a
        iny

        lda (ptr1),y
        sta $6b
        iny

        lda (ptr1),y
        sta $6c
        iny

        lda (ptr1),y
        sta $6d
        iny

        lda (ptr1),y
        sta $6e
        ; sign compare
        eor $66
        sta $6f

        rts

;
; return 32bit float value
;
  .importzp sreg

___float_fac_to_float:

.if 1=0
        ldx #0
@l:
        lda $61,x
        sta $0400+(2*40),x
        inx
        cpx #6
        bne @l
.endif

        lda $66 ; sign
        sta sreg+1
        lda $61 ; exp
        sta sreg
        ldx $62 ; mantissa
        lda $63; mantissa
        rts

__float_fac_to_float:
        sta ptr1
        stx ptr1+1
        ldy #$00

        lda $61
        sta (ptr1),y
        iny

        lda $62
        sta (ptr1),y
        iny

        lda $63
        sta (ptr1),y
        iny

        lda $64
        sta (ptr1),y
        iny

        lda $65
        sta (ptr1),y
        iny

        lda $66
        sta (ptr1),y

        rts

__float_fac_to_float_packed:
        sta ptr1
        stx ptr1+1
        ldy #4

        lda $65
        sta (ptr1),y
        dey

        lda $64
        sta (ptr1),y
        dey

        lda $63
        sta (ptr1),y
        dey

        lda #$66
        ora #$7f
        and $62
        sta (ptr1),y
        dey

        lda $61
        sta (ptr1),y

        rts

__float_arg_to_float_packed:
        sta ptr1
        stx ptr1+1
        ldy #4

        lda $65+8
        sta (ptr1),y
        dey

        lda $64+8
        sta (ptr1),y
        dey

        lda $63+8
        sta (ptr1),y
        dey

        lda #$66+8
        ora #$7f
        and $62+8
        sta (ptr1),y
        dey

        lda $61+8
        sta (ptr1),y

        rts

;---------------------------------------------------------------------------------------------

; convert float to string
; void _ftos(char *d,FLOATFAC *s)
__ftostr:
        jsr ___float_float_to_fac    ; also pops pointer to float
        jsr __basicon
        jsr BASIC_FAC_to_string
        jsr __basicoff
        jsr popax ; ptr to string
        sta ptr1
        stx ptr1+1
        ldy #$00
@l:
        lda $0100,y
        sta (ptr1),y
        beq @s
        iny
        bne @l
@s:
        rts

__strtof:
        jsr popax
        sta $22
        stx $23
        ldy #$00
@l:
        lda ($22),y
        beq @s
        iny
        bne @l
@s:
        tya
        jsr __basicon
        jsr BASIC_string_to_FAC
        jsr __basicoff
        jmp ___float_fac_to_float    ; also pops pointer to float

; convert char to float
; void _ctof(FLOATFAC *f,char v);
__ctof:
        jsr popa
        ;a: low
        jsr __basicon
        jsr BASIC_s8_to_FAC
        jsr __basicoff
        jmp ___float_fac_to_float

; convert unsigned char to float
; void _utof(FLOATFAC *f,unsigned char v);
__utof:
        jsr popa
        ;a: low
        jsr __basicon
        jsr BASIC_u8_to_FAC
        jsr __basicoff
        jmp ___float_fac_to_float

; convert short to float
; void _stof(FLOATFAC *f,unsigned short v);
__stof:
        jsr popax
        ;a: low x: high
        stx $62
        sta $63
        ldx #$90
        sec
        jsr __basicon
        jsr BASIC_u16_to_FAC
        jsr __basicoff
        jmp ___float_fac_to_float

; convert integer to float
; void _itof(FLOATFAC *f,int v);
__itof:
        ;y: low a: high
        jsr popya
        ;a: low x: high
        ;y: low a: high
        jsr __basicon
        jsr BASIC_s16_to_FAC
        jsr __basicoff
        jmp ___float_fac_to_float

; convert float to integer
; void _itof(FLOATFAC *f);
__ftoi:
        jsr ___float_float_to_fac    ; also pops pointer to float
        jsr __basicon
        jsr BASIC_FAC_to_u16
        jsr __basicoff
        ldx $64
        lda $65
        rts

;---------------------------------------------------------------------------------------------
; macros needed as function templates
;---------------------------------------------------------------------------------------------

.macro __ffunc1 addr
        jsr ___float_float_to_fac    ; also pops pointer to float
        jsr __basicon
        jsr addr
        jsr __basicoff
        jmp ___float_fac_to_float    ; also pops pointer to float
.endmacro

.macro __ffunc2a addr
        jsr ___float_float_to_fac_arg
        lda $61
        jsr __basicon
        jsr addr
        jsr __basicoff
        jmp ___float_fac_to_float
.endmacro

.macro __ffunc2b addr
        jsr ___float_float_to_fac_arg
        jsr __basicon
        jsr addr
        jsr __basicoff
        jmp ___float_fac_to_float
.endmacro

;---------------------------------------------------------------------------------------------
; these functions take one arg (in FAC) and return result (in FAC) aswell
;---------------------------------------------------------------------------------------------

__fabs:    __ffunc1 BASIC_FAC_Abs
__fatn:    __ffunc1 BASIC_FAC_Atn
__fcos:    __ffunc1 BASIC_FAC_Cos
__fexp:    __ffunc1 BASIC_FAC_Exp
;__ffre:    __ffunc1 BASIC_FAC_Fre
__fint:    __ffunc1 BASIC_FAC_Int
__flog:    __ffunc1 BASIC_FAC_Log
;__fpos:    __ffunc1 BASIC_FAC_Pos
__frnd:    __ffunc1 BASIC_FAC_Rnd
__fsgn:    __ffunc1 BASIC_FAC_Sgn
__fsin:    __ffunc1 BASIC_FAC_Sin
__fsqr:    __ffunc1 BASIC_FAC_Sqr
__ftan:    __ffunc1 BASIC_FAC_Tan
__fnot:    __ffunc1 BASIC_FAC_Not
__fround:  __ffunc1 BASIC_FAC_Round

;---------------------------------------------------------------------------------------------
; these functions take two args (in FAC and ARG) and return result (in FAC)
;---------------------------------------------------------------------------------------------

__fadd:   __ffunc2a BASIC_ARG_FAC_Add
__fsub:   __ffunc2a BASIC_ARG_FAC_Sub
__fmul:   __ffunc2a BASIC_ARG_FAC_Mul
__fdiv:   __ffunc2a BASIC_ARG_FAC_Div
__fpow:   __ffunc2a BASIC_ARG_FAC_Pow

__fand:   __ffunc2b BASIC_ARG_FAC_And
__for:    __ffunc2b BASIC_ARG_FAC_Or

__fcmp:
        jsr ___float_float_to_fac_arg
        lda #<tempfloat
        ldx #>tempfloat
        jsr __float_arg_to_float_packed

        lda #<tempfloat
        ldy #>tempfloat

        jsr __basicon
        jsr BASIC_FAC_cmp
        jsr __basicoff
        ldx #0
        rts

__ftestsgn:
        jsr ___float_float_to_fac
        jsr __basicon
        jsr BASIC_FAC_testsgn
        jsr __basicoff
        ldx #0
        rts

;---------------------------------------------------------------------------------------------
; polynom1 f(x)=a1+a2*x^2+a3*x^3+...+an*x^n
;---------------------------------------------------------------------------------------------
__fpoly1:
        jsr ___float_float_to_fac
        jsr popya
        jsr __basicon
        jsr BASIC_FAC_Poly1
        jsr __basicoff
        jmp ___float_fac_to_float

;---------------------------------------------------------------------------------------------
; polynom2 f(x)=a1+a2*x^3+a3*x^5+...+an*x^(2n-1)
;---------------------------------------------------------------------------------------------
__fpoly2:
        jsr ___float_float_to_fac
        jsr popya
        jsr __basicon
        jsr BASIC_FAC_Poly1
        jsr __basicoff
        jmp ___float_fac_to_float

__float_atn_fac:
        jsr __basicon
        jsr BASIC_FAC_Atn
        jmp __basicoff

__float_div_fac_arg:
        lda $61
        jsr __basicon
        jsr BASIC_ARG_FAC_Div
        jmp __basicoff

__float_add_fac_arg:
        lda $61
        jsr __basicon
        jsr BASIC_ARG_FAC_Add
        jmp __basicoff

__float_swap_fac_arg:
        lda $61
        ldx $69
        stx $61
        sta $69
        lda $62
        ldx $6a
        stx $62
        sta $6a
        lda $63
        ldx $6b
        stx $63
        sta $6b
        lda $64
        ldx $6c
        stx $64
        sta $6c
        lda $65
        ldx $6d
        stx $65
        sta $6d
        lda $66
        ldx $6e
        stx $66
        sta $6e
        rts

__fneg:
        jsr ___float_float_to_fac    ; also pops pointer to float
        lda $61       ; FAC Exponent
        beq @sk
        lda $66       ; FAC Sign
        eor #$FF
        sta $66       ; FAC Sign
@sk:
        jmp ___float_fac_to_float    ; also pops pointer to float

; void _fatan2(float *a,float *x,float *y)
__fatan2:
        jsr ___float_float_to_fac_arg
        lda $69
        beq @s11  ; =0
        lda $6e
        rol a
        lda #$ff
        bcs @s
        lda #$01
@s:
        bpl @s12   ; <0
      ; arg>0
                ; a=atn(y/x)
                jsr __float_swap_fac_arg
                jsr __float_div_fac_arg
                jsr __float_atn_fac
                jmp ___float_fac_to_float
@s12: ; arg<0
                ; a=atn(y/x)+pi
                jsr __float_swap_fac_arg
                jsr __float_div_fac_arg
                jsr __float_atn_fac
                lda #<__f_pi
                ldx #>__f_pi
                jsr __float_float_to_arg
                jsr __float_add_fac_arg
                jmp ___float_fac_to_float

@s11: ; arg=0
                lda $61
                beq @s21   ; =0
                lda $66
                rol a
                lda #$ff
                bcs @s23
                lda #$01

@s23:
                bpl @s22   ; <0
      ; fac >0
                        ; a= 0.5*pi
                        lda #<__f_pi2
                        ldx #>__f_pi2
                        jsr __float_float_to_fac
                        jmp ___float_fac_to_float
      ; fac =0
@s21:
                        ; a= 0
                        lda #$00
                        sta $62
                        jmp ___float_fac_to_float
      ; fac <0
@s22:
                        ; a= 1.5*pi
                        lda #<__f_1pi2
                        ldx #>__f_1pi2
                        jsr __float_float_to_fac
                        jmp ___float_fac_to_float


        .export __f_0,__f_256
        .export __f_pi2,__f_pi,__f_1pi2,__f_2pi

__f_0:    .byte $00,$80+$00,$00,$00,$00,$00
__f_256:  .byte $89,$80+$00,$00,$00,$00,$00

__f_pi2:  .byte $81,$80+$49,$0f,$da,$a1,$00
__f_pi:   .byte $82,$80+$49,$0f,$da,$a1,$00
__f_1pi2: .byte $83,$80+$16,$cb,$e3,$f9,$00
__f_2pi:  .byte $83,$80+$49,$0f,$da,$a1,$00

tempfloat:  .res 5
