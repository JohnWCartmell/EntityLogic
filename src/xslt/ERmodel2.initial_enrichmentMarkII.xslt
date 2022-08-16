<xsl:transform version="2.0" 
        xmlns="http://www.entitymodelling.org/ERmodel"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:era="http://www.entitymodelling.org/ERmodel"
        xpath-default-namespace="http://www.entitymodelling.org/ERmodel">

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

  <xsl:include href="ERmodel.functions.module.xslt"/>

  <xsl:key name="EntityTypes" 
         match="absolute|entity_type|group" 
         use="if(string-length(name)=0 and self::absolute) then 'EMPTYVALUEREPLACED' else name"/>



  <xsl:key name="IncomingCompositionRelationships" 
         match="composition" 
         use="type"/>
  <xsl:key name="CompRelsByDestTypeAndInverseName" 
         match="composition" 
         use="era:packArray((type,inverse))"/>
  <xsl:key name="AllRelationshipBySrcTypeAndName"
         match="reference|composition|dependency|constructed_relationship"
         use ="../descendant-or-self::entity_type/era:packArray((name,current()/name))" />

  <!-- Make copy template available as a default -->
  <xsl:template match="*" >
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:include href="ERmodel2.initial_enrichmentMarkII.module.xslt"/>

  <xsl:template match="/">
      <!-- an initial enrichment (see ERmodel2.initial_enrichment.module.xslt)        -->
      <xsl:call-template name="initial_enrichment">
        <xsl:with-param name="document" select="."/>
      </xsl:call-template>
  </xsl:template>

</xsl:transform>