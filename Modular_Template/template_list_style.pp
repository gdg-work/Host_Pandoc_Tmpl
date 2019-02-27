!quiet
!def(generate_list_style)
~~~~~~~~~~~~~~~~~~~~~~
<text:list-style style:name="List" style:display-name="List General">
  <text:list-level-style-bullet text:level="1" text:style-name="Bullet_20_Symbols" text:bullet-char="✓">
    <style:list-level-properties text:space-before="0.75cm" text:min-label-width="1.499cm" text:min-label-distance="0.75cm"/>
    <style:text-properties fo:font-family="OpenSymbol" style:font-charset="x-symbol"/>
  </text:list-level-style-bullet>
  <text:list-level-style-bullet text:level="2" text:style-name="Bullet_20_Symbols" text:bullet-char="•">
    <style:list-level-properties text:space-before="1.5cm" text:min-label-width="1.499cm" text:min-label-distance="0.75cm"/>
    <style:text-properties fo:font-family="OpenSymbol" style:font-charset="x-symbol"/>
  </text:list-level-style-bullet>
  <text:list-level-style-bullet text:level="3" text:style-name="Bullet_20_Symbols" text:bullet-char="-">
    <style:list-level-properties text:space-before="2.249cm" text:min-label-width="1.499cm" text:min-label-distance="0.75cm"/>
    <style:text-properties fo:font-family="OpenSymbol" style:font-charset="x-symbol"/>
  </text:list-level-style-bullet>
  <text:list-level-style-bullet text:level="4" text:style-name="Bullet_20_Symbols" text:bullet-char="*">
    <style:list-level-properties text:space-before="2.999cm" text:min-label-width="1.499cm" text:min-label-distance="0.75cm"/>
    <style:text-properties fo:font-family="OpenSymbol" style:font-charset="x-symbol"/>
  </text:list-level-style-bullet>
  <text:list-level-style-bullet text:level="5" text:style-name="Bullet_20_Symbols" text:bullet-char="◦">
    <style:list-level-properties text:space-before="3.749cm" text:min-label-width="1.499cm" text:min-label-distance="0.75cm"/>
    <style:text-properties fo:font-family="OpenSymbol" style:font-charset="x-symbol"/>
  </text:list-level-style-bullet>
</text:list-style>

<style:style style:name="ListPara" style:display-name="List Paragraph general" 
  style:family="paragraph" 
  style:parent-style-name="Standard"
  style:class="text">
  <style:paragraph-properties 
    fo:margin-left="0cm" 
    fo:margin-right="0cm" 
    fo:margin-top="0cm" 
    fo:margin-bottom="0cm" 
    loext:contextual-spacing="false" 
    fo:text-align="justify" 
    style:justify-single-word="false" 
    fo:text-indent="0.75cm" 
    style:auto-text-indent="false"/>
  <style:text-properties 
    style:font-name="Verdana" 
    fo:font-family="Verdana" 
    style:font-style-name="Обычный" 
    style:font-family-generic="swiss" 
    style:font-pitch="variable" 
    fo:font-size="10pt"/>
</style:style>

<style:style style:name="List" style:family="paragraph" style:parent-style-name="ListPara" style:class="list">
  <style:paragraph-properties fo:margin-left="0.75cm" fo:margin-right="0cm" fo:text-indent="0cm" style:auto-text-indent="false">
    <style:tab-stops/>
  </style:paragraph-properties>
  <style:text-properties style:font-name-complex="Verdana1" style:font-family-complex="Verdana"/>

</style:style>
~~~~~~~~~~~~~~~~~~~~~~
