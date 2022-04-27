/**************************************************************************
 Program:  Voices_style_rtf.sas
 Library:  General
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/23/17
 Version:  SAS 9.4
 Environment:  Windows
 
 Description:  Create ODS style Styles.Voices_style_rtf for
 VoicesDMV survey tables.

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;

** Register fonts **;

proc fontreg;
   fontpath "%sysget(systemroot)\fonts";
run;

** New style for RTF output **;

proc template;
  define style Styles.Voices_style_rtf;
    parent=styles.rtf;
       style Table from Output /
             /** Cell background color **/
             Background=_undef_
             /** Border color **/
             Bordercolor=cx626366
             /** Lines between columns and rows **/
             Rules=all
             /** Lines around table **/
             frame=box;
       style header from header /
             /** Background color for col. headers **/
             /*background=_undef_*/
             background=cx95ac3b
             foreground=white
             /** Don't change this (enables RTF special characters) **/
             protectspecialchars=off;
       style rowheader from rowheader /
             /** Background color for row headers **/
             background=_undef_
             foreground=black
             /** Font for row headers **/
             font=fonts('docFont')
             /** Don't change this (enables RTF special characters) **/
             protectspecialchars=off;
       replace fonts /
        /** Main table font **/
        'docFont' = ("Calibri",9pt)
        /** Heading fonts **/
        'headingEmphasisFont' = ("Calibri",9pt,Bold Italic)
        'headingFont' = ("Calibri",9pt,Bold)
        'StrongFont' = ("Calibri",9pt,Bold)
        'EmphasisFont' = ("Calibri",9pt,Italic)
        /** Title & footnote fonts **/
        'TitleFont' = ("Calibri",11pt)
        'TitleFont2' = ("Calibri",11pt)
        /** Fixed-width fonts **/
        'FixedEmphasisFont' = ("Courier New, Courier",9pt,Italic)
        'FixedStrongFont' = ("Courier New, Courier",9pt,Bold)
        'FixedHeadingFont' = ("Courier New, Courier",9pt,Bold)
        'BatchFixedFont' = ("SAS Monospace, Courier New, Courier",6.7pt)
        'FixedFont' = ("Courier New, Courier",9pt);
      style body from body /
        /** Document page margins **/
        leftmargin=0.5in
        rightmargin=0.5in
        topmargin=0.5in
        bottommargin=0.5in
        protectspecialchars=off;
      style systemtitle from systemtitle /
        foreground=cx00637c
        /** Don't change this (enables RTF special characters) **/
        protectspecialchars=off;
      style systemfooter from systemfooter /
        /** Don't change this (enables RTF special characters) **/
        protectspecialchars=off;
      style data from data /
        /** Don't change this (enables RTF special characters) **/
        protectspecialchars=off;
  end;
  
  source styles.printer;
  source styles.rtf;
  source Styles.Voices_style_rtf;

run;

