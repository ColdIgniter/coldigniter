<!---
 * Describes foreign characters for transliteration with the text helper.
 *
 * Difference: a character is written as the escape \uXXXX of the regular
 * expression (the source holds ASCII only), which matches the same
 * character.
--->
<cfcomponent output="no" hint="Describes foreign characters for transliteration with the text helper">

	<!---
	 * The list of foreign characters.
	 *
	 * A map (see array_()) of patterns to replacements, in order.
	 *
	 * @var array<string, string>
	--->
	<cfset this.characterList = CreateObject("java", "java.util.LinkedHashMap").init()>
	<cfset this.characterList["/\u00e4|\u00e6|\u01fd/"] = "ae">
	<cfset this.characterList["/\u00f6|\u0153/"] = "oe">
	<cfset this.characterList["/\u00fc/"] = "ue">
	<cfset this.characterList["/\u00c4/"] = "Ae">
	<cfset this.characterList["/\u00dc/"] = "Ue">
	<cfset this.characterList["/\u00d6/"] = "Oe">
	<cfset this.characterList["/\u00c0|\u00c1|\u00c2|\u00c3|\u00c4|\u00c5|\u01fa|\u0100|\u0102|\u0104|\u01cd|\u0391|\u0386|\u1ea2|\u1ea0|\u1ea6|\u1eaa|\u1ea8|\u1eac|\u1eb0|\u1eae|\u1eb4|\u1eb2|\u1eb6|\u0410/"] = "A">
	<cfset this.characterList["/\u00e0|\u00e1|\u00e2|\u00e3|\u00e5|\u01fb|\u0101|\u0103|\u0105|\u01ce|\u00aa|\u03b1|\u03ac|\u1ea3|\u1ea1|\u1ea7|\u1ea5|\u1eab|\u1ea9|\u1ead|\u1eb1|\u1eaf|\u1eb5|\u1eb3|\u1eb7|\u0430/"] = "a">
	<cfset this.characterList["/\u0411/"] = "B">
	<cfset this.characterList["/\u0431/"] = "b">
	<cfset this.characterList["/\u00c7|\u0106|\u0108|\u010a|\u010c/"] = "C">
	<cfset this.characterList["/\u00e7|\u0107|\u0109|\u010b|\u010d/"] = "c">
	<cfset this.characterList["/\u0414/"] = "D">
	<cfset this.characterList["/\u0434/"] = "d">
	<cfset this.characterList["/\u00d0|\u010e|\u0110|\u0394/"] = "Dj">
	<cfset this.characterList["/\u00f0|\u010f|\u0111|\u03b4/"] = "dj">
	<cfset this.characterList["/\u00c8|\u00c9|\u00ca|\u00cb|\u0112|\u0114|\u0116|\u0118|\u011a|\u0395|\u0388|\u1ebc|\u1eba|\u1eb8|\u1ec0|\u1ebe|\u1ec4|\u1ec2|\u1ec6|\u0415|\u042d/"] = "E">
	<cfset this.characterList["/\u00e8|\u00e9|\u00ea|\u00eb|\u0113|\u0115|\u0117|\u0119|\u011b|\u03ad|\u03b5|\u1ebd|\u1ebb|\u1eb9|\u1ec1|\u1ebf|\u1ec5|\u1ec3|\u1ec7|\u0435|\u044d/"] = "e">
	<cfset this.characterList["/\u0424/"] = "F">
	<cfset this.characterList["/\u0444/"] = "f">
	<cfset this.characterList["/\u011c|\u011e|\u0120|\u0122|\u0393|\u0413|\u0490/"] = "G">
	<cfset this.characterList["/\u011d|\u011f|\u0121|\u0123|\u03b3|\u0433|\u0491/"] = "g">
	<cfset this.characterList["/\u0124|\u0126/"] = "H">
	<cfset this.characterList["/\u0125|\u0127/"] = "h">
	<cfset this.characterList["/\u00cc|\u00cd|\u00ce|\u00cf|\u0128|\u012a|\u012c|\u01cf|\u012e|\u0130|\u0397|\u0389|\u038a|\u0399|\u03aa|\u1ec8|\u1eca|\u0418|\u042b/"] = "I">
	<cfset this.characterList["/\u00ec|\u00ed|\u00ee|\u00ef|\u0129|\u012b|\u012d|\u01d0|\u012f|\u0131|\u03b7|\u03ae|\u03af|\u03b9|\u03ca|\u1ec9|\u1ecb|\u0438|\u044b|\u0457/"] = "i">
	<cfset this.characterList["/\u0134/"] = "J">
	<cfset this.characterList["/\u0135/"] = "j">
	<cfset this.characterList["/\u0136|\u039a|\u041a/"] = "K">
	<cfset this.characterList["/\u0137|\u03ba|\u043a/"] = "k">
	<cfset this.characterList["/\u0139|\u013b|\u013d|\u013f|\u0141|\u039b|\u041b/"] = "L">
	<cfset this.characterList["/\u013a|\u013c|\u013e|\u0140|\u0142|\u03bb|\u043b/"] = "l">
	<cfset this.characterList["/\u041c/"] = "M">
	<cfset this.characterList["/\u043c/"] = "m">
	<cfset this.characterList["/\u00d1|\u0143|\u0145|\u0147|\u039d|\u041d/"] = "N">
	<cfset this.characterList["/\u00f1|\u0144|\u0146|\u0148|\u0149|\u03bd|\u043d/"] = "n">
	<cfset this.characterList["/\u00d2|\u00d3|\u00d4|\u00d5|\u014c|\u014e|\u01d1|\u0150|\u01a0|\u00d8|\u01fe|\u039f|\u038c|\u03a9|\u038f|\u1ece|\u1ecc|\u1ed2|\u1ed0|\u1ed6|\u1ed4|\u1ed8|\u1edc|\u1eda|\u1ee0|\u1ede|\u1ee2|\u041e/"] = "O">
	<cfset this.characterList["/\u00f2|\u00f3|\u00f4|\u00f5|\u014d|\u014f|\u01d2|\u0151|\u01a1|\u00f8|\u01ff|\u00ba|\u03bf|\u03cc|\u03c9|\u03ce|\u1ecf|\u1ecd|\u1ed3|\u1ed1|\u1ed7|\u1ed5|\u1ed9|\u1edd|\u1edb|\u1ee1|\u1edf|\u1ee3|\u043e/"] = "o">
	<cfset this.characterList["/\u041f/"] = "P">
	<cfset this.characterList["/\u043f/"] = "p">
	<cfset this.characterList["/\u0154|\u0156|\u0158|\u03a1|\u0420/"] = "R">
	<cfset this.characterList["/\u0155|\u0157|\u0159|\u03c1|\u0440/"] = "r">
	<cfset this.characterList["/\u015a|\u015c|\u015e|\u0218|\u0160|\u03a3|\u0421/"] = "S">
	<cfset this.characterList["/\u015b|\u015d|\u015f|\u0219|\u0161|\u017f|\u03c3|\u03c2|\u0441/"] = "s">
	<cfset this.characterList["/\u021a|\u0162|\u0164|\u0166|\u03c4|\u0422/"] = "T">
	<cfset this.characterList["/\u021b|\u0163|\u0165|\u0167|\u0442/"] = "t">
	<cfset this.characterList["/\u00d9|\u00da|\u00db|\u0168|\u016a|\u016c|\u016e|\u0170|\u0172|\u01af|\u01d3|\u01d5|\u01d7|\u01d9|\u01db|\u0168|\u1ee6|\u1ee4|\u1eea|\u1ee8|\u1eee|\u1eec|\u1ef0|\u0423/"] = "U">
	<cfset this.characterList["/\u00f9|\u00fa|\u00fb|\u0169|\u016b|\u016d|\u016f|\u0171|\u0173|\u01b0|\u01d4|\u01d6|\u01d8|\u01da|\u01dc|\u03c5|\u03cd|\u03cb|\u1ee7|\u1ee5|\u1eeb|\u1ee9|\u1eef|\u1eed|\u1ef1|\u0443/"] = "u">
	<cfset this.characterList["/\u01b3|\u024e|\u1ef4|\u1e8e|\u04f2|\u04ee|\u040e|\u00dd|\u0178|\u0176|\u03a5|\u038e|\u03ab|\u1ef2|\u1ef8|\u1ef6|\u1ef4|\u0419/"] = "Y">
	<cfset this.characterList["/\u1e99|\u028f|\u01b4|\u024f|\u1ef5|\u1e8f|\u04f3|\u04ef|\u045e|\u00fd|\u00ff|\u0177|\u1ef3|\u1ef9|\u1ef7|\u1ef5|\u0439/"] = "y">
	<cfset this.characterList["/\u0412/"] = "V">
	<cfset this.characterList["/\u0432/"] = "v">
	<cfset this.characterList["/\u0174/"] = "W">
	<cfset this.characterList["/\u0175/"] = "w">
	<cfset this.characterList["/\u0179|\u017b|\u017d|\u0396|\u0417/"] = "Z">
	<cfset this.characterList["/\u017a|\u017c|\u017e|\u03b6|\u0437/"] = "z">
	<cfset this.characterList["/\u00c6|\u01fc/"] = "AE">
	<cfset this.characterList["/\u00df/"] = "ss">
	<cfset this.characterList["/\u0132/"] = "IJ">
	<cfset this.characterList["/\u0133/"] = "ij">
	<cfset this.characterList["/\u0152/"] = "OE">
	<cfset this.characterList["/\u0192/"] = "f">
	<cfset this.characterList["/\u03be/"] = "ks">
	<cfset this.characterList["/\u03c0/"] = "p">
	<cfset this.characterList["/\u03b2/"] = "v">
	<cfset this.characterList["/\u03bc/"] = "m">
	<cfset this.characterList["/\u03c8/"] = "ps">
	<cfset this.characterList["/\u0401/"] = "Yo">
	<cfset this.characterList["/\u0451/"] = "yo">
	<cfset this.characterList["/\u0404/"] = "Ye">
	<cfset this.characterList["/\u0454/"] = "ye">
	<cfset this.characterList["/\u0407/"] = "Yi">
	<cfset this.characterList["/\u0416/"] = "Zh">
	<cfset this.characterList["/\u0436/"] = "zh">
	<cfset this.characterList["/\u0425/"] = "Kh">
	<cfset this.characterList["/\u0445/"] = "kh">
	<cfset this.characterList["/\u0426/"] = "Ts">
	<cfset this.characterList["/\u0446/"] = "ts">
	<cfset this.characterList["/\u0427/"] = "Ch">
	<cfset this.characterList["/\u0447/"] = "ch">
	<cfset this.characterList["/\u0428/"] = "Sh">
	<cfset this.characterList["/\u0448/"] = "sh">
	<cfset this.characterList["/\u0429/"] = "Shch">
	<cfset this.characterList["/\u0449/"] = "shch">
	<cfset this.characterList["/\u042a|\u044a|\u042c|\u044c/"] = "">
	<cfset this.characterList["/\u042e/"] = "Yu">
	<cfset this.characterList["/\u044e/"] = "yu">
	<cfset this.characterList["/\u042f/"] = "Ya">
	<cfset this.characterList["/\u044f/"] = "ya">

</cfcomponent>
