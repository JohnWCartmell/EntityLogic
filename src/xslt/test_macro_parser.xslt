<xsl:transform version="2.0" 
        xmlns="http://www.entitymodelling.org/ERmodel"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:fns="http://www.w3.org/2005/xpath-functions"
        xmlns:era="http://www.entitymodelling.org/ERmodel"
        xpath-default-namespace="http://www.entitymodelling.org/ERmodel">

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

  <!-- Make copy template available as a default -->
  <xsl:template match="*" >
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="entity_model"> 
  <xsl:copy>
    <!-- add prefixes for namespaces -->
    <xsl:namespace name="xs" select="'http://www.w3.org/2001/XMLSchema'"/>
    <xsl:namespace name="fns" select="'http://www.w3.org/2005/xpath-functions'"/>
    <xsl:namespace name="era" select="'http://www.entitymodelling.org/ERmodel'"/>
    <xsl:namespace name="er-js" select="'http://www.entitymodelling.org/ERmodel/javascript'"/>  

    <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>

  <xsl:template match="optional" priority="90">
    <xsl:copy>
      <xsl:apply-templates/>
      <xsl:variable name="analysis" select="analyze-string(xpath_calculation_macro,'#\w+|\$\$\w+','sx')"/>
      <xpath_template>
          <xsl:apply-templates select="$analysis/*" mode="template"/>
      </xpath_template>
      <actuals>
        <xsl:apply-templates select="$analysis/fns:match" mode="actuals"/>
      </actuals>
    </xsl:copy>
  </xsl:template>

   <xsl:template match="fns:match" mode="actuals">
    <xsl:message>match actual</xsl:message>
    <attr>
       <xsl:value-of select="."/>
    </attr>
  </xsl:template>

  <xsl:template match="fns:non-match" mode="template">
    <xsl:message>WILDCARD non match<xsl:value-of select="name()"/></xsl:message>
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="fns:match" mode="template">
    <xsl:message>TEMPLATE match</xsl:message>
    <xsl:value-of select="'$$'"/>
  </xsl:template>

  <!-- XXXXXXXXXXXXXXXXXXXX -->




</xsl:transform>