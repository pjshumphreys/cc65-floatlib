var i  = 0;

var functionsList = [
  ["BASIC_FAC_to_string", 0xBDDD, "FUNC0"],   /* in: FAC value   out: str at $0100 a/y ptr to str */
  ["BASIC_string_to_FAC", 0xB7B5, "FUNC0"],   /* in: $22/$23 ptr to str,a=strlen out: FAC value */

  ["BASIC_s8_to_FAC",     0xBC3C, "FUNC0"],	  /* a: value */
  ["BASIC_u8_to_FAC",     0xB3A2, "FUNC0"],	  /* y: value */

  ["BASIC_u16_to_FAC",    0xBC49, "FUNC0"],   /* a/y:lo/hi value (sta $62 sty $63 sec ldx#$90 jsr...) */
  ["BASIC_s16_to_FAC",    0xB395, "FUNC0"],   /* a/y:lo/hi value */
  ["BASIC_FAC_to_u16",    0xBC9B, "FUNC0"],   /* in:FAC out: y/a:lo/hi value */

/*--------------------------------------------------------------------------------------------- */
/* these functions take one arg (in FAC) and return result (in FAC) aswell */
/*--------------------------------------------------------------------------------------------- */

  ["__fabs",       0xBC58, "FUNC1"],   /* in/out: FAC */
  ["__fatn",       0xE30E, "FUNC1"],   /* in/out: FAC */
  ["__fcos",       0xE264, "FUNC1"],   /* in/out: FAC */
  ["__fexp",       0xBFED, "FUNC1"],   /* in/out: FAC */
/* __ffre:    FUNC1 BASIC_FAC_Fre */
  ["__fint",       0xBCCC, "FUNC1"],   /* in/out: FAC */
  ["__flog",       0xB9EA, "FUNC1"],   /* in/out: FAC */
/* __fpos:    FUNC1 BASIC_FAC_Pos */
  ["__frnd",       0xE097, "FUNC1"],   /* in/out: FAC */
  ["__fsgn",       0xBC39, "FUNC1"],   /* in/out: FAC */
  ["__fsin",       0xE26B, "FUNC1"],   /* in/out: FAC */
  ["__fsqr",       0xBF71, "FUNC1"],   /* in/out: FAC */
  ["__ftan",       0xE2B4, "FUNC1"],   /* in/out: FAC */
  ["__fnot",       0xAED4, "FUNC1"],   /* in/out: FAC */
  ["__fround",     0xBC1B, "FUNC1"],   /* in/out: FAC */

/*--------------------------------------------------------------------------------------------- */
/* these functions take two args (in FAC and ARG) and return result (in FAC) */
/*--------------------------------------------------------------------------------------------- */

  ["__fadd",   0xB86A, "FUNC2"],   /* in: ARG,FAC out:FAC */
  ["__fsub",   0xB853, "FUNC2"],   /* in: ARG,FAC out:FAC */
  ["__fmul",   0xBA2B, "FUNC2"],   /* in: ARG,FAC out:FAC */
  ["__fdiv",   0xBB12, "FUNC2"],   /* in: ARG,FAC out:FAC */
  ["__fpow",   0xBF7B, "FUNC2"],   /* in: ARG,FAC out:FAC */

  ["__fand",   0xAFE9, "FUNC3"],   /* in: ARG,FAC out:FAC */
  ["__for",    0xAFE6, "FUNC3"],   /* in: ARG,FAC out:FAC */

  ["BASIC_FAC_cmp",       0xBC5B, "FUNC0"],   /* in: FAC(x1) a/y ptr lo/hi to x2 out: a=0 (x1=x2) a=1 (x1>x2) a=255 (x1<x2) */
  ["BASIC_FAC_testsgn",   0xBC2B, "FUNC0"],   /* in: FAC(x1) out: a=0 (x1=0) a=1 (x1>0) a=255 (x1<0) */
  ["BASIC_FAC_Poly1",     0xE059, "FUNC0"],   /* in: FAC x  a/y ptr to poly (1byte grade,5bytes per coefficient) */
  ["BASIC_FAC_Atn",       0xE30E, "FUNC0"],   /* in/out: FAC */
  ["BASIC_ARG_FAC_Div",   0xBB12, "FUNC0"],   /* in: ARG,FAC out:FAC */
  ["BASIC_ARG_FAC_Add",   0xB86A, "FUNC0"]    /* in: ARG,FAC out:FAC */
];

//console.log(".import xRegBackup, aRegBackup");
console.log("xRegBackup: .byte $00\naRegBackup: .byte $00");

for(i = 0; i < functionsList.length; i++) {
  console.log(functionsList[i][0]+":\n  stx xRegBackup\n  ldx #$" + ("00"+(i.toString(16).toUpperCase())).substr(-2) + "\n  jmp "+ functionsList[i][2]);
}

console.log("\nhighAddressTable:");
for(i = 0; i < functionsList.length; i++) {
  console.log(".byte $"+("0000"+((functionsList[i][2]-1).toString(16).toUpperCase())).substr(-4).substring(0,2));
}

console.log("\nlowAddressTable:");
for(i = 0; i < functionsList.length; i++) {
  console.log(".byte $"+("00"+((functionsList[i][2]-1).toString(16).toUpperCase())).substr(-2));
}
