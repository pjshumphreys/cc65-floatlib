var i  = 0;

var functionsList = [
  ["BASIC_FAC_to_string", 0xBDDD, "FUNC1"],   /* in: FAC value   out: str at $0100 a/y ptr to str */
  ["BASIC_string_to_FAC", 0xB7B5, "FUNC1"],   /* in: $22/$23 ptr to str,a=strlen out: FAC value */

  ["BASIC_s8_to_FAC",     0xBC3C, "FUNC1"],	  /* a: value */
  ["BASIC_u8_to_FAC",     0xB3A2, "FUNC1"],	  /* y: value */

  ["BASIC_u16_to_FAC",    0xBC49, "FUNC1"],   /* a/y:lo/hi value (sta $62 sty $63 sec ldx#$90 jsr...) */
  ["BASIC_s16_to_FAC",    0xB395, "FUNC1"],   /* a/y:lo/hi value */
  ["BASIC_FAC_to_u16",    0xBC9B, "FUNC1"],   /* in:FAC out: y/a:lo/hi value */


/*--------------------------------------------------------------------------------------------- */
/* these functions take one arg (in FAC) and return result (in FAC) aswell */
/*--------------------------------------------------------------------------------------------- */

  ["BASIC_FAC_Abs",       0xBC58, "FUNC1"],   /* in/out: FAC */
  ["BASIC_FAC_Atn",       0xE30E, "FUNC1"],   /* in/out: FAC */
  ["BASIC_FAC_Cos",       0xE264, "FUNC1"],   /* in/out: FAC */
  ["BASIC_FAC_Exp",       0xBFED, "FUNC1"],   /* in/out: FAC */
/* __ffre:    __ffunc1 BASIC_FAC_Fre */
  ["BASIC_FAC_Int",       0xBCCC, "FUNC1"],   /* in/out: FAC */
  ["BASIC_FAC_Log",       0xB9EA, "FUNC1"],   /* in/out: FAC */
/* __fpos:    __ffunc1 BASIC_FAC_Pos */
  ["BASIC_FAC_Rnd",       0xE097, "FUNC1"],   /* in/out: FAC */
  ["BASIC_FAC_Sgn",       0xBC39, "FUNC1"],   /* in/out: FAC */
  ["BASIC_FAC_Sin",       0xE26B, "FUNC1"],   /* in/out: FAC */
  ["BASIC_FAC_Sqr",       0xBF71, "FUNC1"],   /* in/out: FAC */
  ["BASIC_FAC_Tan",       0xE2B4, "FUNC1"],   /* in/out: FAC */
  ["BASIC_FAC_Not",       0xAED4, "FUNC1"],   /* in/out: FAC */
  ["BASIC_FAC_Round",     0xBC1B, "FUNC1"],   /* in/out: FAC */

/*--------------------------------------------------------------------------------------------- */
/* these functions take two args (in FAC and ARG) and return result (in FAC) */
/*--------------------------------------------------------------------------------------------- */

  ["BASIC_ARG_FAC_Add",   0xB86A, "FUNC1"],   /* in: ARG,FAC out:FAC */
  ["BASIC_ARG_FAC_Sub",   0xB853, "FUNC1"],   /* in: ARG,FAC out:FAC */
  ["BASIC_ARG_FAC_Mul",   0xBA2B, "FUNC1"],   /* in: ARG,FAC out:FAC */
  ["BASIC_ARG_FAC_Div",   0xBB12, "FUNC1"],   /* in: ARG,FAC out:FAC */
  ["BASIC_ARG_FAC_Pow",   0xBF7B, "FUNC1"],   /* in: ARG,FAC out:FAC */



  ["BASIC_ARG_FAC_And",   0xAFE9, "FUNC1"],   /* in: ARG,FAC out:FAC */
  ["BASIC_ARG_FAC_Or",    0xAFE6, "FUNC1"],   /* in: ARG,FAC out:FAC */

  ["BASIC_FAC_cmp",       0xBC5B, "FUNC1"],   /* in: FAC(x1) a/y ptr lo/hi to x2 out: a=0 (x1=x2) a=1 (x1>x2) a=255 (x1<x2) */
  ["BASIC_FAC_testsgn",   0xBC2B, "FUNC1"],   /* in: FAC(x1) out: a=0 (x1=0) a=1 (x1>0) a=255 (x1<0) */

  ["BASIC_FAC_Poly1",     0xE059, "FUNC1"],   /* in: FAC x  a/y ptr to poly (1byte grade,5bytes per coefficient) */
  ["BASIC_FAC_Atn",       0xE30E, "FUNC1"],   /* in/out: FAC */
  ["BASIC_FAC_Atn",       0xE30E, "FUNC1"],   /* in/out: FAC */
  ["BASIC_ARG_FAC_Div",   0xBB12, "FUNC1"],   /* in: ARG,FAC out:FAC */
  ["BASIC_ARG_FAC_Add",   0xB86A, "FUNC1"]    /* in: ARG,FAC out:FAC */
];

for(i = 0; i < functionsList.length; i++) {
  console.log(".export "+functionsList[i][0]);
}

for(i = 0; i < functionsList.length; i++) {
  console.log(functionsList[i][0]+":\n  stx xRegBackup\n  ldx #$" + ("00"+(i.toString(16).toUpperCase())).substr(-2) + "\n  jmp farcall2");
}


console.log("\nhighAddressTable:");
for(i = 0; i < functionsList.length; i++) {
  console.log(".byte $"+("0000"+((functionsList[i][2]-1).toString(16).toUpperCase())).substr(-4).substring(0,2));
}

console.log("\nlowAddressTable:");
for(i = 0; i < functionsList.length; i++) {
  console.log(".byte $"+("00"+((functionsList[i][2]-1).toString(16).toUpperCase())).substr(-2));
}
