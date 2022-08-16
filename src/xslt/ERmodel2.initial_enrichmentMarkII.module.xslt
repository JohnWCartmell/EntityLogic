<!-- 

****************************************************************
13-Oct-2017 J.Cartmell Refine scope display text. If subject reference 
                       relationship is mandatory display as equality (=) if not
                       display as less than or equal.
15-Mar-2019 J.Cartmell Modify display text of scope. 
                       Change from ~p=q to D:p=S:q 
                       where D is Destination and S is Source
16-Aug-2022 J.Cartmell UPGRADED to latest metamodel  regarding cardinality and attribute 
16-Aug-2022 J Cartmell Recode into a pure style - one attribute per template.
                       Merge initial pass and recursive pass into a single recursive path.
                       Do this incrementally moving one or two attributes at a time into recurivse path.
-->

<!-- 
Description
 This is an  initial enrichment that applies to a logical ER model.
 It is implmented as an initial pass followed by a recusrive enrichment.
     
 (1) It adds namespaces to the root entity_model element.
     Currently these are xs, era and era-js.
     (TBD are these all necessary? Are they used? Need document.)

 (2) It creates the following derived attributes:
     
      absolute => 
            identifier : string,   # see entity_type.identifier
            elementName : string   # xml element name - not necessarily unique

     entity_type => 
            identifier : string,  # based on name but syntactically 
                                  # an identifier whilst still being unique
            elementName : string, # xml element name - not necessarily unique
            parentType : string   # the pipe ('|') separated types 
                                  # from which there are incoming 
                                  # composition relationships

     composition|reference => 
            id:string             # a short id of form R<n> for some n

     reference =>
        scope_display_text : string r,;
                                 # text presentation of the scope constraint
                                 # using ~/<riser text>=<diag text>
                                 # using D:<riser text>=S:<diag text>
        optional projection : entity ;
                                 # if the reference is specified as the 
                                 # projection_rel by a pullback. 
     projection => 
         host_type : string      # the source entity type of the pullback
                                 # composition relationship 
                                 # this is '' if absolute is the source
          

     dependency => optional identifying : ()
 

      navigation ::= identity | theabsolute | join | aggregate | component
      
      navigation =>
        src : string,           # the name of the source entity type
        dest : string,          # the name of the destination entity type
        display_text : string   # text presentation of the navigation using
                                #       / for join
                                #       . for the identity
                                #       ^ for the absolute

      join | component => identification_status : ('Identifying', 'NotIdentifying')

            
 DISCUSSION POINTS 
 (1) In future this first enrichment of a 
     logical entity model should complete missing detail inferred by 
     the model. Examples might be creating inverses to relationships,
     adding default cardinalities, creating composition relationships 
     from depndency relationships.
 (2) In future much of this can be generated from defintions of
     derived attributes in the meta-model ERmodelERmodel.
    
CHANGE HISTORY
CR-18553 JC  19-Oct-2016 Created
CR-18123 JC  25-Oct-2016 Generalise the 'dest' enrichment to entity
                        type navigation. Remove mangleName attribute.
                        Add identifier attribute.
CR-18657 JC  7-Nov-2016 Add scope_display_text and display_text attributes
                        and guard first_pass attributes to make 
                        this enrichment idempotent.
CR18720 JC  16-Nov-2016 Use packArray function from ERmodel.functions.module.xslt
CR18708 JC  18-Nov-2016 Add projection entity for a reference relationship
                        that is specified as a projection_rel for a pullback.
                        This was previously implemented in ERmodel2.ts.xslt.
CR-19407 JC 20-Feb-2017 Creation of seqNo attributews moved out into physical entrichment pass.
-->

<xsl:transform version="2.0" 
        xmlns="http://www.entitymodelling.org/ERmodel"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:era="http://www.entitymodelling.org/ERmodel"
        xpath-default-namespace="http://www.entitymodelling.org/ERmodel">


<xsl:template name="initial_enrichment">
   <xsl:param name="document"/>
   <xsl:variable name="current_state">
      <xsl:for-each select="$document">
         <xsl:copy>
             <xsl:apply-templates mode="initial_enrichment_first_pass"/>
         </xsl:copy>
      </xsl:for-each>
   </xsl:variable>
   <xsl:call-template name="initial_enrichment_recursive">
      <xsl:with-param name="interim" select="$current_state"/>
   </xsl:call-template>
</xsl:template>

<xsl:template name="initial_enrichment_recursive">
   <xsl:param name="interim"/>
   <xsl:variable name ="next">
      <xsl:for-each select="$interim">
         <xsl:copy>
           <xsl:apply-templates mode="initial_enrichment_recursive"/>
         </xsl:copy>
      </xsl:for-each>
   </xsl:variable>
   <xsl:variable name="result">
      <xsl:choose>
         <xsl:when test="not(deep-equal($interim,$next))">     <!-- CR-18553 -->
            <xsl:message> changed in initial enrichment recursive</xsl:message>
            <xsl:call-template name="initial_enrichment_recursive">
               <xsl:with-param name="interim" select="$next"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:message> unchanged fixed point of initial enrichment recursive </xsl:message>
            <xsl:copy-of select="$interim"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:variable>  
   <xsl:copy-of select="$result"/>
</xsl:template>

<!-- In the first pass just add namespace definitions -->
<xsl:template match="*"
              mode="initial_enrichment_first_pass"> 
  <xsl:copy>
    <xsl:apply-templates mode="initial_enrichment_first_pass"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="entity_model"
              mode="initial_enrichment_first_pass"
              priority="1"> 
  <xsl:copy>
    <!-- add prefixes for namespaces -->
    <xsl:namespace name="xs" select="'http://www.w3.org/2001/XMLSchema'"/>
    <xsl:namespace name="era" select="'http://www.entitymodelling.org/ERmodel'"/>
    <xsl:namespace name="er-js" select="'http://www.entitymodelling.org/ERmodel/javascript'"/>  
    <xsl:apply-templates mode="initial_enrichment_first_pass"/>
  </xsl:copy>
</xsl:template>

<!-- recursive enrichment starts here -->
<xsl:template match="*[self::absolute|self::entity_type]
                     [not(identifier)]
                     "
              mode="initial_enrichment_recursive"
              priority="2">
  <xsl:copy>
      <identifier>
          <xsl:value-of select="translate(replace(name,'\((\d)\)','_$1'),
                                          ' ',
                                          '_'
                                         )
                               "/>
      </identifier>
      <xsl:apply-templates mode="initial_enrichment_recursive"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="*[self::absolute|self::entity_type]
                      [not(elementName)]
                      " mode="initial_enrichment_recursive"
              priority="3">
  <xsl:copy> 
       <elementName>
          <xsl:value-of select="translate(replace(name,'\(\d\)',''),
                                          ' ',
                                          '_'
                                         )
                               "/>
       </elementName>
    <xsl:apply-templates mode="initial_enrichment_recursive"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="composition
                     [not(id)]
                    "
              mode="initial_enrichment_recursive"
              priority="4">
   <xsl:copy>
       <id>
          <xsl:text>S</xsl:text>  <!-- S for structure -->
          <xsl:number count="composition" level="any" />
       </id>
       <xsl:apply-templates mode="initial_enrichment_recursive"/>
    </xsl:copy>
</xsl:template>

<xsl:template match="reference
                     [not(id)]" 
              mode="initial_enrichment_recursive"
              priority="5">
   <xsl:copy>
       <id>
          <xsl:text>R</xsl:text>
          <xsl:number count="reference" level="any" />
       </id>
       <xsl:apply-templates mode="initial_enrichment_recursive"/>
    </xsl:copy>
</xsl:template>


<xsl:variable name="keywords" as="xs:string *">
   <xsl:sequence select="
          '', 'do', 'if', 'in', 'for', 'let', 'new', 'try', 'var', 'case',
          'else', 'enum', 'eval', 'null', 'this', 'true', 'void', 'with',
          'break', 'catch', 'class', 'const', 'false', 'super', 'throw',
          'while', 'yield', 'delete', 'export', 'import', 'public', 'return',
          'static', 'switch', 'typeof', 'default', 'extends', 'finally',
          'package', 'private', 'continue', 'debugger', 'function', 'arguments',
          'interface', 'protected', 'implements', 'instanceof'   "/>
</xsl:variable>

<!-- in the logic below there were two cases prior to 16 Aug 2022
      one case used outgoing depdency and its type and other incoming compsoition
       we cannot rely on dependency/type because this isnt present for compositions from absolute
                  so why not just rely on incoming compositions?
                  -->
<xsl:template match="entity_type
                     [not(parentType)]
                     " 
              mode="initial_enrichment_recursive"
              priority="6">
   <xsl:copy>
      <parentType> 
         <xsl:value-of select="string-join(key('IncomingCompositionRelationships',
                                       ancestor-or-self::entity_type/name)/../name,
                                     ' | ')"/>
      </parentType>
       <xsl:apply-templates mode="initial_enrichment_recursive"/>
   </xsl:copy>
</xsl:template>

<!-- following might be considered unnecesarily inefficient because of recursion -->
<!-- BTW: I feel like this is a pullback -->
<xsl:template match="dependency
                     [key('CompRelsByDestTypeAndInverseName',                   
                         era:packArray((../name,name)))/identifying]
                     [not(identifying)]
                     "
              mode="initial_enrichment_recursive"
              priority="7"> 
  <xsl:copy>
      <identifying/>
      <xsl:apply-templates mode="initial_enrichment_recursive"/>
   </xsl:copy>
</xsl:template>

<!-- as before, this feels like a pullback to me -->
<xsl:template match="reference
              [key('IncomingCompositionRelationships', ../name)/pullback/projection_rel = name]
              [not(projection)]" 
              mode="initial_enrichment_recursive" 
              priority="6">
   <xsl:copy>
       <projection/>
       <xsl:apply-templates mode="initial_enrichment_recursive"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="*"
              mode="initial_enrichment_recursive"> 
  <xsl:copy>
    <xsl:apply-templates mode="initial_enrichment_recursive"/>
  </xsl:copy>
</xsl:template>


<xsl:template match="reference
                     [not(scope_display_text)]
                     [riser/*/display_text]
                     [diagonal/*/display_text]
              "
              priority="999"
              mode="initial_enrichment_recursive"> 
  <xsl:copy>
     <xsl:apply-templates mode="initial_enrichment_recursive"/>
          <xsl:variable name="operator" select="if (cardinality/ZeroOrOne or cardinality=ZeroOneOrMore) then '=' else 'LTEQ'"/>  
                   <!-- 13-Oct-2017  'LTEQ' code will be translated by ERmodel2.svg.xslt -->             
                  <!-- 16 August 2022 - UPGRADED to latest metamodel  cardinality but note code wasn't correct to start with -->
          <scope_display_text>
             <xsl:value-of select="concat('d:',riser/*/display_text,'=s:',diagonal/*/display_text)"/>
             <!-- was        <xsl:value-of select="concat('~/',riser/*/display_text,'=',diagonal/*/display_text)"/> -->
          </scope_display_text>
  </xsl:copy>
</xsl:template>

<xsl:template match="reference/projection
                     [not(host_type)]"
              mode="initial_enrichment_recursive"
              priority="7">
  <xsl:copy>
    <xsl:apply-templates mode="initial_enrichment_recursive"/>
        <host_type>
            <xsl:for-each select="key('IncomingCompositionRelationships', ../../name)/..">
               <xsl:value-of select="if (self::absolute) then '' else name"/>
            </xsl:for-each>
        </host_type>
  </xsl:copy>
</xsl:template>

<!-- display_text -->
<xsl:template match="identity
                     [not(display_text)]
                    " 
              priority="8"
              mode="initial_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates mode="initial_enrichment_recursive"/>
      <display_text>
         <xsl:value-of select="'.'"/>
      </display_text>
   </xsl:copy>
</xsl:template>

<xsl:template match="theabsolute
                     [not(display_text)]
                     " 
              priority="9"
              mode="initial_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates mode="initial_enrichment_recursive"/>
      <display_text>
         <xsl:value-of select="'^'"/>
      </display_text>
   </xsl:copy>
</xsl:template>

<xsl:template match="join
                     [not(display_text)]
                     [every $component in component satisfies $component/display_text]
                     "
                     priority="10"
                     mode="initial_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates mode="initial_enrichment_recursive"/>
      <display_text>
         <xsl:value-of select="string-join(component/display_text,'/')"/>
      </display_text>
   </xsl:copy>
</xsl:template>

<xsl:template match="component
                     [not(display_text)]" 
                     priority="11"
                     mode="initial_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates mode="initial_enrichment_recursive"/>
      <display_text>
         <xsl:value-of select="rel"/>
      </display_text>
   </xsl:copy>
</xsl:template>

<!-- changes to attributes of identity have not been tested --> 
<xsl:template match="along/*[self::identity|self::theabsolute]
                     [not(src)]
                     " 
              priority="12"
              mode="initial_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates mode="initial_enrichment_recursive"/>
      <src>
         <xsl:value-of select="ancestor::entity_type/name"/>
      </src>
   </xsl:copy>
</xsl:template>

<xsl:template match="riser2/*[self::identity|self::theabsolute]
                     [not(src)]
                     " 
              priority="13"
              mode="initial_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates mode="initial_enrichment_recursive"/>
      <src>
         <xsl:value-of select="(ancestor::pullback|ancestor::copy)/type"/>
      </src>
   </xsl:copy>
</xsl:template>

<xsl:template match="riser/*[self::identity|self::theabsolute]
                     [not(src)]
                     " 
              priority="14"
              mode="initial_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates mode="initial_enrichment_recursive"/>
      <src>
         <xsl:value-of select="ancestor::reference[1]/type"/>
      </src>
   </xsl:copy>
</xsl:template>

<xsl:template match="*[self::diagonal|self::constructed_relationship]/*[self::identity|self::theabsolute]
                     [not(src)]
                     " 
              priority="15"
              mode="initial_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates mode="initial_enrichment_recursive"/>
      <src>
         <xsl:value-of select="ancestor::entity_type[1]/name"/>
      </src>
   </xsl:copy>
</xsl:template>

 <xsl:template match="identity
                      [not(dest)]
                      [src]
                      " 
               priority="16"
               mode="initial_enrichment_recursive">
   <xsl:copy> 
      <xsl:apply-templates mode="initial_enrichment_recursive"/>
      <dest>
         <xsl:value-of select="src"/>
      </dest>
   </xsl:copy>
</xsl:template>

<xsl:template match="join
                     [not(src)]
                     [component[1]/src]
                     " 
              priority="17"
              mode="initial_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates mode="initial_enrichment_recursive"/>     
      <src>
         <xsl:value-of select="component[1]/src"/>
      </src>
   </xsl:copy>
</xsl:template>

 <xsl:template match="join
                      [not(dest)]
                      [component[last()]/dest]
                      " 
               priority="18"
               mode="initial_enrichment_recursive">
   <xsl:copy> 
      <xsl:apply-templates mode="initial_enrichment_recursive"/>
      <dest>
         <xsl:value-of select="component[last()]/dest"/>
      </dest>
   </xsl:copy>
</xsl:template>

<xsl:template match="join
                     [not(identification_status)]
                     [every $component in component satisfies $component/identification_status]" 
              priority="19"
              mode="initial_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates mode="initial_enrichment_recursive"/>
      <identification_status>
            <xsl:value-of select="if (every $component in component 
                                      satisfies ($component/identification_status = 'Identifying')
                                     )
                                  then 'Identifying'
                                  else 'NotIdentifying'
                                 "/>
      </identification_status>
   </xsl:copy>
</xsl:template>

<!-- not sure that I benefit from spliting the following and further-->
<xsl:template match="component
                     [not(src)]
                     [not(preceding-sibling::component)]
                     " 
                     priority="20"
                     mode="initial_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates mode="initial_enrichment_recursive"/>    
      <xsl:choose>
         <xsl:when test="ancestor::along">
            <src>
               <xsl:value-of select="ancestor::entity_type/name"/>
            </src>
         </xsl:when>
         <xsl:when test="ancestor::riser2">
            <src>
               <xsl:value-of select="(ancestor::pullback|ancestor::copy)/type"/>
            </src>
         </xsl:when>
         <xsl:when test="ancestor::riser">
            <src>
               <xsl:value-of select="ancestor::reference[1]/type"/>
            </src>
         </xsl:when>
         <xsl:otherwise>  <!-- diagonal or constructed relationship -->
            <src>
               <xsl:value-of select="ancestor::entity_type[1]/name"/>
            </src>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:copy>
</xsl:template>

<xsl:template match="component
                     [not(src)]
                     [preceding-sibling::component[1]/dest]
                     " 
                     priority="21"
                     mode="initial_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates mode="initial_enrichment_recursive"/>
      <src>
         <xsl:value-of select="preceding-sibling::component[1]/dest"/>
      </src>
   </xsl:copy>
</xsl:template>

<xsl:template match="component
                     [not(dest)]
                     [src]
                     " 
                     priority="22"
                     mode="initial_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates mode="initial_enrichment_recursive"/>
         <dest>
            <xsl:value-of select="key('AllRelationshipBySrcTypeAndName',
                                      era:packArray((src,rel)))
                                  /type"/>
         </dest>
   </xsl:copy>
</xsl:template>

<xsl:template match="component
                     [not(identification_status)]
                     [src]
                     " 
                     priority="23"
                     mode="initial_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates mode="initial_enrichment_recursive"/>
      <identification_status>   
         <xsl:value-of select="if(key('AllRelationshipBySrcTypeAndName',
                                            era:packArray((src,rel)))
                                       /identifying)
                                    then 'Identifying'
                                    else 'NotIdentifying'
                                   "/>  
      </identification_status>
   </xsl:copy>
</xsl:template>

</xsl:transform>

