

<!--
*************************************
ERmodel2.xpath_enrichment.module.xslt
*************************************

DESCRIPTION
  This xslt enriches a physical ER model by the attributes described below.
  It is implemented as a recursive enrichment.

      absolute =>
         xpath_qualified_type_classifier : string

      entity_type =>
         xpath_type_classifier :string,  # for a concrete type this is the 
                                        # element name
                                        # for an abstract type it is
                                        # the pattern A|B|C ...
                                        # where A, B, C are the 
                                        # concrete (leaf) descendant types
         xpath_qualified_element_name : string,
                                        # this is only defined for concrete types.
                                        # it is the same as elementName if
                                        # elementName is unique
                                        # it is a path of elementNames from
                                        # root of the document otherwise
                                        # Implication is that entity type names
                                        # must be unique in presence of
                                        # recursion
         xpath_qualified_type_classifier : string,
                                        # similar to xpath_type_classifier
                                        # but with A'|B'|C'..
                                        # where A',B'C' are qualified 
                                        # elementNames, see 
                                        # xpath_qualified_element_name
                                        # to make element name unique
         xpath_parent_entity : string ,
         xpath_primary_key : string,
         xpath_type_check : string




      composition/pullback =>
         xpath_iterate: string, # xpath expression relative to the context
                                # of the parent entity of the composition. 
                                # Used in validating or elaborating the 
                                # pullback. When evaluated for a host
                                # entity navigates the composition by
                                # going around the other three sides of
                                # the square. If any candidate entity not 
                                # represented in the pullback returns it
                                # instead of the pullback.
         xpath_resolve_candidate : string
                                # an xpath (sub)expression relative to the context
                                # of a pullback candidate and a current node
                                # which is the pullback host entity.
                                # used only in generation of xpath_iterate
         pbe_passno : nonNegativeNumber
                                # pullback elaboration pass no
                                # if non-zero then the pullback pass no during 
                                # which this pullback will be elaborated
                                
      
      reference =>
        xpath_is_defined : string,
        xpath_type_check : string,
        xpath_local_key :  string, # that part of the foreign key that is 
                                   # constructed from attributes local to the 
                                   # host entity  plus the <key> constraint
        xpath_foreign_key : string,
        xpath_evaluate : string,
        pbe_passno : nonNegativeNumber
                                # used as an intermediate in the
                                # calculation of pbe_passno for a pullback
      
      dependency =>
        xpath_evaluate : string
        pbe_passno : nonNegativeNumber
                                # used as an intermediate in the
                                # calculation of pbe_passno for a pullback

      reference/projection =>
        xpath_delta_key : string,
                  # This is a temporary used only in the generation
                  # of xpath_inverse_fragment.
                  # This is an xpath to be evaluated in the context of 
                  # an entity of type the destination entity type of the
                  # reference. It evaluates to that part of the primary key
                  # of the putative destination entity required to identify
                  # it relative to the destination of the riser.
        xpath_inverse_fragment :string;
                  # This is a temporary used only in the generation of
                  # pullback/xpath_resolve_candidate.
                  # This xpath is a subexpression to be evaluated
                  # relative to a context entity of the type of the
                  # destination of the host reference relationship
                  # and with the host entity of the pullabck as
                  # the current node.
      
      theabsolute =>
        xpath_evaluate : string
        xpath_evaluate_inverse : string
        pbe_passno : nonNegativeNumber
                                # used as an intermediate in the
                                # calculation of pbe_passno for a pullback
      
      join =>
        xpath_evaluate : string
        xpath_evaluate_inverse : string
        pbe_passno : nonNegativeNumber
                                # used as an intermediate in the
                                # calculation of pbe_passno for a pullback
      
      identity =>
        xpath_evaluate : string
        xpath_evaluate_inverse : string
        pbe_passno : nonNegativeNumber
                                # used as an intermediate in the
                                # calculation of pbe_passno for a pullback
      
      component =>
        xpath_evaluate : string,
        xpath_evaluate_inverse : string
        xpath_delta_key : optional string  
                         # This is a temporary used only in the
                         # generation of 
                         # reference/projection/xpath_delta_key
                         # only defined for components of risers.
                         # It is empty except in the case
                         # of components that navigate an  identifying
                         # dependency in  which case it is an xpath to 
                         # be evaluated within the context of the src 
                         # entity of  the component. For this entity it
                         # evaluates to that part of the  primary key 
                         # of the src required to identify with respect 
                         # to the destination of the riser that is 
                         # contributed by navigating the dependency.  
        pbe_passno : nonNegativeNumber
                                # used as an intermediate in the
                                # calculation of pbe_passno for a pullback

DISCUSSION
  It would be neat to replace the xpath naming prefix with an xpath namespace and 
  to move out attributes other than xpath attributes as commented on above.

CHANGE HISTORY

CR18159 JC  30-Aug-2016 In generation of xpath_foreign_key implement support
                        for the key directive of a reference relationship.

CR18553 JC  21-Oct-2016 This module created from ERmodel2.physical.xslt.

CR18159 JC  18-Oct-2016 In the generation of xpath_foreign_key do not include
            26-Oct-2016 the primary key of the destination entity type of the
                        riser unless all the rising relationships are identifying.
            01-Nov-2016 Treat a missing diagonal as being same as theabsolute.
CR18708     16-Nov-2016 Add xpath_iterate and xpath_resolve_candidate attributes.
                        Intoduce a new function era:packArray
CR18720 JC  16-Nov-2016 Use packArray function from ERmodel.functions.module.xslt

22-Sept-2017 JC Bug fix the generation of xpath_qualified_element_name. 

16-Aug-2022 J.Cartmell UPGRADED to latest metamodel  regarding cardinality and attribute 
-->

<xsl:transform version="2.0" 
        xmlns="http://www.entitymodelling.org/ERmodel"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:era="http://www.entitymodelling.org/ERmodel"
        xpath-default-namespace="http://www.entitymodelling.org/ERmodel">

<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:key name="entity_type" 
       match="entity_type|group" 
       use="name"/>
<xsl:key name="inverse_implementationOf" 
       match="implementationOf"
       use="era:packArray((../../name,rel))"/>

<xsl:template name="recursive_xpath_enrichment">
  <xsl:param name="mode" />
  <xsl:param name="interim"/>
  <xsl:variable name ="next">
    <xsl:for-each select="$interim">
      <xsl:copy>
        <xsl:apply-templates mode="recursive_xpath_enrichment"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="result">
    <xsl:choose>
      <xsl:when test="not(deep-equal($interim,$next))">
        <xsl:message> changed in xpath enrichment</xsl:message>
        <xsl:call-template name="recursive_xpath_enrichment">
          <xsl:with-param name="interim" select="$next"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message> unchanged fixed point of xpath enrichment</xsl:message>
        <xsl:copy-of select="$interim"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>  
  <xsl:copy-of select="$result"/>
</xsl:template>

<xsl:template match="*" mode="recursive_xpath_enrichment">
  <xsl:copy>
    <xsl:apply-templates mode="recursive_xpath_enrichment"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="absolute" mode="recursive_xpath_enrichment">
  <xsl:copy>
    <xsl:apply-templates mode="recursive_xpath_enrichment"/>
    <xsl:if test="not(xpath_qualified_type_classifier)">
      <xpath_qualified_type_classifier>
        <xsl:value-of select="elementName"/>
      </xpath_qualified_type_classifier>
    </xsl:if>
  </xsl:copy>
</xsl:template>

<xsl:template match="entity_type" mode="recursive_xpath_enrichment">
  <xsl:copy>
    <xsl:apply-templates mode="recursive_xpath_enrichment"/>
    <xsl:if test="not(xpath_type_classifier)">
      <xpath_type_classifier>
        <xsl:value-of select="string-join(descendant-or-self::entity_type[not(entity_type)]/elementName,'|')"/>
      </xpath_type_classifier>
    </xsl:if>
    <xsl:if test="not(xpath_qualified_element_name)">
      <xsl:if test="not(entity_type)">
        <xsl:choose>
          <xsl:when test="count(//entity_type[elementName=current()/elementName]) = 1">
            <xpath_qualified_element_name>
              <xsl:value-of select="elementName"/>
            </xpath_qualified_element_name>
          </xsl:when>
          <xsl:otherwise>
            <!-- 22-Sept-2017 Fix this test using every 
            <xsl:if test="key('entity_type',parentType)/xpath_qualified_type_classifier">
            -->      
            <xsl:if test="every $parent_type 
                          in key('AllIncomingCompositionRelationships',name)/..
                          satisfies boolean($parent_type/xpath_qualified_type_classifier)">  
              <xpath_qualified_element_name>
                <xsl:variable name="contexts" as="xs:string*">
                  <xsl:for-each select="key('AllIncomingCompositionRelationships',name)">
                    <xsl:variable name="postfix">
                      <xsl:if test="name">
                        <xsl:text>/*</xsl:text>
                      </xsl:if>
                    </xsl:variable>
                    <xsl:for-each select="tokenize(../xpath_qualified_type_classifier,
                                                              '\|')">
                      <xsl:value-of select="concat(.,$postfix)"/>
                    </xsl:for-each>
                  </xsl:for-each>
                </xsl:variable>
                <xsl:value-of select="concat(string-join($contexts,concat('/', elementName,'|')),'/',elementName)"/>
              </xpath_qualified_element_name>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:if>
    <xsl:if test="not(xpath_qualified_type_classifier)">
      <xsl:if test="not(entity_type) and xpath_qualified_element_name">
        <xpath_qualified_type_classifier>
          <xsl:value-of select="xpath_qualified_element_name"/>
        </xpath_qualified_type_classifier>
      </xsl:if>
      <xsl:if test="entity_type and (
                     every $et in descendant-or-self::entity_type[not(entity_type)]
                     satisfies boolean($et/xpath_qualified_element_name))" >

        <xpath_qualified_type_classifier>
          <xsl:value-of select="string-join(descendant-or-self::entity_type[not(entity_type)]/
                                                     xpath_qualified_element_name,
                                                   '|')"/>
        </xpath_qualified_type_classifier>
      </xsl:if>
    </xsl:if>
    <xsl:if test="not(xpath_parent_entity)">
      <xpath_parent_entity>    <!-- This could be improved to work in more circumstances 
                                           - this implementation assumes all incoming compositions require the same navigation -->
        <xsl:text>..</xsl:text>     <!-- 31 Aug 2016 WAS ../ -->
        <xsl:if test="key('AllIncomingCompositionRelationships',name)/name">
          <xsl:text>/..</xsl:text>   <!-- 31 Aug 2016 WAS .. -->
        </xsl:if>
      </xpath_parent_entity>
    </xsl:if>
    <xsl:if test="not(xpath_local_key)">
      <xpath_local_key>
        <xsl:choose>
          <xsl:when test="count(ancestor-or-self::entity_type/attribute[identifying]/name)=1">    <!-- 16 August 2022 - UPGRADED to latest metamodel  value >>> attribute  -->
            <xsl:value-of select="ancestor-or-self::entity_type/attribute[identifying]/name"/>    <!-- 16 August 2022 - UPGRADED to latest metamodel  value >>> attribute  -->
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>era:packArray((</xsl:text>
            <xsl:value-of select="string-join(ancestor-or-self::entity_type/attribute[identifying]/name,',')"/> <!-- 16 August 2022 - UPGRADED to latest metamodel  value >>> attribute -->
            <xsl:text>))</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xpath_local_key>
    </xsl:if>
    <xsl:if test="not(xpath_primary_key) and xpath_local_key and xpath_parent_entity">
      <xsl:choose>
        <xsl:when test="../name()='absolute' or not(exists(key('AllIncomingCompositionRelationships',name)[identifying]))">
          <xpath_primary_key>
            <xsl:value-of select="xpath_local_key"/>
          </xpath_primary_key>
        </xsl:when>
        <xsl:when test="every $entity 
                             in  key('AllIncomingCompositionRelationships',name)/.. 
                             satisfies boolean($entity/xpath_primary_key)">
          <xpath_primary_key>
            <xsl:choose>
              <xsl:when test="key('AllIncomingCompositionRelationships',name)[identifying/inherited]">   
                <xsl:value-of select="concat(xpath_parent_entity,'/')"/>
                <xsl:text>descendant-or-self::entity_type/</xsl:text>    <!-- CHANGE THIS MAKE MORE GENERIC -->
                <xsl:if test="exists(ancestor-or-self::entity_type/attribute[identifying])">                             <!-- 16 August 2022 - UPGRADED to latest metamodel  value >>> attribute  -->
                  <xsl:text>concat(</xsl:text>
                </xsl:if>
                <!-- parent primary key -->
                <xsl:value-of select="key('AllIncomingCompositionRelationships',name)/../xpath_primary_key"/>
                <xsl:if test="exists(ancestor-or-self::entity_type/attribute[identifying])">                            <!-- 16 August 2022 - UPGRADED to latest metamodel  value >>> attribute  -->
                  <xsl:text>,':',current()/</xsl:text>
                  <xsl:value-of select="ancestor-or-self::entity_type/attribute[identifying]/name"/>                    <!-- 16 August 2022 - UPGRADED to latest metamodel  value >>> attribute  -->
                  <!-- what if many of these - a bug in the above I think JC 16-Nov-2016  -->
                  <!-- this bourne out by AX1X2BCD entity type C primary key              -->
                  <xsl:text>)</xsl:text>
                </xsl:if>
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="xpath_local_key=''">
                    <xsl:value-of select="xpath_parent_entity"/>
                    <xsl:text>/</xsl:text>
                    <!-- parent primary key -->
                    <xsl:value-of select="key('AllIncomingCompositionRelationships',name)/../xpath_primary_key"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>era:packArray((</xsl:text>
                    <xsl:value-of select="xpath_parent_entity"/>
                    <xsl:text>/</xsl:text>
                    <!-- parent primary key -->
                    <xsl:value-of select="key('AllIncomingCompositionRelationships',name)/../xpath_primary_key"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="xpath_local_key"/>
                    <xsl:text>))</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xpath_primary_key>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="not(xpath_typecheck)">
      <xsl:choose>
        <xsl:when test="not(entity_type)">  <!-- is a concrete type -->
          <xsl:if test="elementName">
            <xpath_typecheck>
              <xsl:value-of select="concat('self::',elementName)"/>
            </xpath_typecheck>
          </xsl:if>
        </xsl:when>  
        <xsl:otherwise>     <!-- abstract entity type -->
          <xsl:if test="every $child_et in descendant-or-self::entity_type[not(entity_type)] satisfies boolean($child_et/xpath_typecheck)">
            <xpath_typecheck>
              <xsl:value-of select="string-join(descendant-or-self::entity_type[not(entity_type)]/xpath_typecheck,'|')"/>  
            </xpath_typecheck>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:copy>
</xsl:template>

<xsl:template match="composition" mode="recursive_xpath_enrichment">
  <xsl:copy>
     <xsl:apply-templates mode="recursive_xpath_enrichment"/>
     <!-- pbe_passno -->
     <xsl:if test="not(pbe_passno)">
        <xsl:choose>
           <xsl:when test="pullback">
               <xsl:if test="pullback/pbe_passno">
                    <pbe_passno>
                        <xsl:value-of select="pullback/pbe_passno"/>
                    </pbe_passno>
               </xsl:if>
           </xsl:when>
           <xsl:otherwise>
               <pbe_passno>
                  <xsl:value-of select="0"/>
               </pbe_passno>
           </xsl:otherwise>
        </xsl:choose>
     </xsl:if>
  </xsl:copy>
</xsl:template>

<xsl:template match="composition/pullback" mode="recursive_xpath_enrichment">
  <xsl:copy>
    <xsl:apply-templates mode="recursive_xpath_enrichment"/>

    <!-- xpath_resolve_candidate -->
    <xsl:if test="not(xpath_resolve_candidate)
                    and key('AllRelationshipBySrcTypeAndName',era:packArray((../type,projection_rel)))/projection/xpath_inverse_fragment
                   ">
      <xpath_resolve_candidate>
        <xsl:text>key('</xsl:text>
        <xsl:value-of select="key('EntityTypes',../type)/identifier"/>
        <xsl:text>',</xsl:text>
        <xsl:value-of select="key('AllRelationshipBySrcTypeAndName',era:packArray((../type,projection_rel)))/projection/xpath_inverse_fragment"/>
        <xsl:text>)</xsl:text>
      </xpath_resolve_candidate>
    </xsl:if>

    <!-- xpath_iterate -->
    <xsl:if test="not(xpath_iterate)
                    and along/*/xpath_evaluate
                    and key('AllRelationshipBySrcTypeAndName',era:packArray((../type,projection_rel)))/riser/*/xpath_evaluate_inverse
                    and xpath_resolve_candidate
                   ">
      <xpath_iterate>
        <xsl:value-of select="along/*/xpath_evaluate"/>
        <xsl:text>/</xsl:text>
        <xsl:value-of select="key('AllRelationshipBySrcTypeAndName',era:packArray((../type,projection_rel)))/riser/*/xpath_evaluate_inverse"/>
        <xsl:text>/ (if (boolean(</xsl:text>
        <xsl:value-of select="xpath_resolve_candidate"/>
        <xsl:text>))then </xsl:text>
        <xsl:value-of select="xpath_resolve_candidate"/>
        <xsl:text> else .)</xsl:text>
      </xpath_iterate>
    </xsl:if>

    <!-- pbe_passno -->
    <xsl:if test="not(pbe_passno)">
       <xsl:if test="key('AllRelationshipBySrcTypeAndName',era:packArray((../type,projection_rel)))/riser/*/pbe_passno">
          <xsl:if test="along/identity">
               <pbe_passno>
                 <xsl:value-of select="max((
                    key('AllRelationshipBySrcTypeAndName',era:packArray((../type,projection_rel)))/riser/*/pbe_passno
                   )) + 1 "/>
               </pbe_passno>
          </xsl:if>
          <xsl:if test="along/*/pbe_passno">
             <pbe_passno>
              <xsl:value-of select="max((
                    key('AllRelationshipBySrcTypeAndName',era:packArray((../type,projection_rel)))/riser/*/pbe_passno,
                    along/*/pbe_passno
                   )) + 1 "/>
             </pbe_passno>
          </xsl:if>
       </xsl:if>
    </xsl:if>
  </xsl:copy>
</xsl:template>


<xsl:template match="reference" mode="recursive_xpath_enrichment">
  <xsl:copy>
    <xsl:apply-templates mode="recursive_xpath_enrichment"/>
    <xsl:variable 
            name="is_implemented_by_fk" as="xs:boolean"
            select="(cardinality/ZeroOrOne or cardinality/ExactlyOne)
                    and  (if (not(inverse)) 
                          then true()
                          else boolean(riser)
                         )
                   "/>                                         <!-- 16 August 2022 - UPGRADED to latest metamodel : cardinality = 'ZeroOrOne' or cardinality = 'ExactlyOne' >>> cardinality/ZeroOrOne or cardinality/ExactlyOne -->

    <!-- xpath_is_defined -->  
    <xsl:if test="not(xpath_is_defined) and $is_implemented_by_fk">
      <xpath_is_defined>
        <xsl:value-of select="string-join(key('inverse_implementationOf',concat(../name,':',name))/../name,' and ')"/>
        <!-- NOTE: This will be empty (which is not correct) when a reference has a key constraint (c.f. CR_18159) but no foreign_keys  -->
        <!-- for now change ERmodel2.referential_integrity.xslt not to plant a ref intgirty check for a reference with a key constraint -->
      </xpath_is_defined>
    </xsl:if>

    <!-- xpath_typecheck -->
    <xsl:if test="not(xpath_typecheck) and $is_implemented_by_fk">
      <xsl:if test="key('EntityTypes',type)/xpath_typecheck">
        <xpath_typecheck>
          <xsl:value-of select="key('EntityTypes',type)/xpath_typecheck"/>
        </xpath_typecheck>
      </xsl:if>
    </xsl:if>

    <!-- xpath_local_key -->
    <xsl:if test="not(xpath_local_key) 
                    and (not(key) 
                        or ( key/*/xpath_evaluate 
                             and key('EntityTypes',key/*/dest)/xpath_primary_key
                           )
                        )
                   ">
      <xpath_local_key>
        <xsl:choose>
          <xsl:when test="key">   <!-- added 30-Aug-2016 CR-18159 created 5-Sept-2016 -->
            <xsl:value-of select="key/*/xpath_evaluate"/>  
            <xsl:text>/</xsl:text>
            <xsl:value-of select="key('EntityTypes',key/*/dest)/xpath_primary_key"/>    <!-- this uses CR-18123: generalise 'dest' relationship -->
          </xsl:when>
          <xsl:otherwise>  <!-- the usual case! --> <!-- simplifying assumption that key and local identifying attribute are exclusive -->
            <xsl:if test="count(key('inverse_implementationOf',concat(../name,':',name))) &gt; 1">
              <xsl:text>concat(</xsl:text>
            </xsl:if>
            <xsl:for-each select="key('inverse_implementationOf',concat(../name,':',name))">
              <xsl:if test="position() &gt; 1">
                <xsl:text>,':',</xsl:text>
              </xsl:if>
              <xsl:value-of select="../name"/>
            </xsl:for-each>
            <xsl:if test="count(key('inverse_implementationOf',concat(../name,':',name))) &gt; 1">
              <xsl:text>)</xsl:text>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xpath_local_key>
    </xsl:if>

    <!-- xpath_foreign_key -->
    <xsl:if test="not(xpath_foreign_key) and $is_implemented_by_fk 
                                           and xpath_local_key
                                           and ( not(diagonal) or diagonal/theabsolute or riser/*/identification_status)" >
      <xsl:choose>
        <xsl:when test="not(diagonal) or diagonal/theabsolute or riser/*/identification_status='NotIdentifying'">
          <xpath_foreign_key>
            <xsl:value-of select="xpath_local_key"/>
          </xpath_foreign_key>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="diagonal/*/xpath_evaluate and riser/*/dest and key('entity_type',riser/*/dest)/xpath_primary_key">    
            <xpath_foreign_key>
              <xsl:text>concat(</xsl:text>
              <xsl:value-of select="diagonal/*/xpath_evaluate"/>  
              <xsl:text>/</xsl:text>
              <xsl:value-of select="key('EntityTypes',riser/*/dest)/xpath_primary_key"/>
              <xsl:text>,':',</xsl:text>
              <xsl:value-of select="xpath_local_key"/>
              <xsl:text>)</xsl:text>
            </xpath_foreign_key>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>

    <!-- xpath_evaluate -->
    <xsl:if test="not(xpath_evaluate) and $is_implemented_by_fk and xpath_foreign_key">
      <xsl:choose>
        <xsl:when test="not(diagonal) or diagonal/theabsolute">
          <xpath_evaluate>
            <xsl:text>key('</xsl:text>
            <xsl:value-of select="key('EntityTypes',type)/identifier"/>
            <xsl:text>', </xsl:text>
            <xsl:value-of select="xpath_foreign_key"/>
            <xsl:text>)</xsl:text>
          </xpath_evaluate>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="diagonal/*/xpath_evaluate"> 
            <xpath_evaluate>
              <xsl:text>key('</xsl:text>
              <xsl:value-of select="key('EntityTypes',type)/identifier"/>
              <xsl:text>', </xsl:text>
              <xsl:value-of select="xpath_foreign_key"/>
              <xsl:if test="riser/*/identification_status='NotIdentifying'"> 
                <!-- if the riser is not all idenitfying then we pass the diagonal as a third parameter to the key lookup.
                             This is simply to ensure that the evaluation is only successful if the scope constraint is satisfied.
                             This check would have to be done differently if the scope constraint model were ever to be made more general.
                        -->
                <xsl:text>, </xsl:text>
                <xsl:value-of select="concat('(',diagonal/*/xpath_evaluate,',.)[1]')"/>      
                <!-- protected by dot as additional possible context to ensure that no run-time error when diagonal undefined -->
              </xsl:if>
              <xsl:text>)</xsl:text>
            </xpath_evaluate>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>

    <!-- pbe_passno -->
    <xsl:if test="not(pbe_passno)">
       <xsl:choose>
          <xsl:when test="projection">
              <xsl:if test="key('IncomingCompositionRelationships', ../name)/pbe_passno">
                 <pbe_passno>
                      <xsl:value-of select="key('IncomingCompositionRelationships', ../name)/pbe_passno"/>
                 </pbe_passno>
              </xsl:if>
          </xsl:when>
          <xsl:when test="not($is_implemented_by_fk) and inverse">
              <xsl:if test="key('RelationshipBySrcTypeAndName', era:packArray((type,inverse)))/pbe_passno">
                 <pbe_passno>
                      <xsl:value-of select="key('RelationshipBySrcTypeAndName', era:packArray((type,inverse)))/pbe_passno"/>
                 </pbe_passno>
              </xsl:if>
          </xsl:when>
          <xsl:otherwise>
              <pbe_passno>
                 <xsl:value-of select="0"/>
              </pbe_passno>
          </xsl:otherwise>
       </xsl:choose>
    </xsl:if>
     
  </xsl:copy>
</xsl:template>

<xsl:template match="reference/projection " mode="recursive_xpath_enrichment">
  <xsl:copy>
    <xsl:apply-templates mode="recursive_xpath_enrichment"/>

    <!-- xpath_delta_key -->
    <xsl:if test="not(xpath_delta_key) 
                    and ../riser/*/xpath_delta_key 
                    and key('EntityTypes',../type)/xpath_local_key">
      <xpath_delta_key>
        <xsl:value-of select="era:combineKey(
                                         ../riser/*/xpath_delta_key,
                                         key('EntityTypes',../type)/xpath_local_key
                                                )
                                 "/>
      </xpath_delta_key>
    </xsl:if>

    <!-- xpath_inverse_fragment -->
    <xsl:if test="not(xpath_inverse_fragment)
                    and (
                         host_type=''
                         or
                         key('EntityTypes',host_type)/xpath_primary_key
                        )
                    and xpath_delta_key
                   ">
      <xpath_inverse_fragment>
        <xsl:value-of select="if (host_type='') 
                              then xpath_delta_key
                              else
                                 era:combineKey(   
                                         concat('current()/',
                                                key('EntityTypes',host_type)/xpath_primary_key
                                               ),
                                         xpath_delta_key
                                                )
                                 "/>
      </xpath_inverse_fragment>
    </xsl:if>

  </xsl:copy>
</xsl:template>

<xsl:template match="dependency" mode="recursive_xpath_enrichment">
  <xsl:copy>
    <xsl:apply-templates mode="recursive_xpath_enrichment"/>

    <!-- xpath_evaluate -->
    <xsl:if test="not(xpath_evaluate)">
      <xpath_evaluate>
        <xsl:choose>
          <xsl:when test="key('IncomingCompositionRelationships',../name)/name">
            <xsl:text>../..</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>..</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xpath_evaluate>
    </xsl:if>

    <!-- xpath_evaluate_inverse -->
    <xsl:if test="not(xpath_evaluate_inverse) 
                    and ../xpath_type_classifier
                   ">
      <xpath_evaluate_inverse>
        <xsl:for-each select="key('IncomingCompositionRelationships',../name)">
          <xsl:if test="name">
            <xsl:value-of select="name"/>
            <xsl:text>/</xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:text>(</xsl:text>
        <xsl:value-of select="../xpath_type_classifier"/>
        <xsl:text>)</xsl:text>
      </xpath_evaluate_inverse>
    </xsl:if>
    
    <!-- pbe_passno -->
    <xsl:if test="not(pbe_passno)">
       <xsl:choose>
           <xsl:when test="key('IncomingCompositionRelationships',../name)/pullback">
               <xsl:if test="key('IncomingCompositionRelationships',../name)/pbe_passno">
                    <pbe_passno>
                         <xsl:value-of select="key('IncomingCompositionRelationships',../name)/pbe_passno"/>
                    </pbe_passno>
               </xsl:if>
          </xsl:when>
          <xsl:otherwise>
              <pbe_passno>
                 <xsl:value-of select="0"/>
              </pbe_passno>
          </xsl:otherwise>
       </xsl:choose>
    </xsl:if>
  </xsl:copy>
</xsl:template>

<xsl:template match="theabsolute" mode="recursive_xpath_enrichment">
  <xsl:copy>
    <xsl:apply-templates mode="recursive_xpath_enrichment"/>

    <!-- xpath_evaluate -->
    <xsl:if test="not(xpath_evaluate)">
      <xpath_evaluate>
        <xsl:text>/</xsl:text><xsl:value-of select="/entity_model/absolute/name"/>
      </xpath_evaluate>
    </xsl:if>

    <!-- xpath_evaluate_inverse -->
    <xsl:if test="not(xpath_evaluate_inverse)">
      <xpath_evaluate_inverse>
        <xsl:text>//</xsl:text><xsl:value-of select="src"/>
      </xpath_evaluate_inverse>
    </xsl:if>

    <!-- pbe_passno -->
    <xsl:if test="not(pbe_passno)">
       <xsl:if test="fix">
          <pbe_passno>
                  <xsl:value-of select="0"/>
          </pbe_passno>
       </xsl:if>
    </xsl:if>

  </xsl:copy>
</xsl:template>

<xsl:template match="join" mode="recursive_xpath_enrichment">
  <xsl:copy>
    <xsl:apply-templates mode="recursive_xpath_enrichment"/>

    <!-- xpath_evaluate -->
    <xsl:if test="not(xpath_evaluate) and (every $component in component satisfies boolean($component/xpath_evaluate))">
      <xpath_evaluate>
        <xsl:value-of select="string-join(component/xpath_evaluate,'/')"/>
      </xpath_evaluate>
    </xsl:if>

    <!-- xpath_evaluate_inverse -->
    <xsl:if test="not(xpath_evaluate_inverse) and (every $component in component satisfies boolean($component/xpath_evaluate_inverse))">
      <xpath_evaluate_inverse>
        <xsl:value-of select="string-join(reverse(component/xpath_evaluate_inverse),'/')"/>
      </xpath_evaluate_inverse>
    </xsl:if>

    <!-- xpath_delta_key -->
    <xsl:if test="not(xpath_delta_key) and component[1]/xpath_delta_key">
      <xpath_delta_key>
        <xsl:value-of select="component[1]/xpath_delta_key"/>
      </xpath_delta_key>
    </xsl:if>

    <!-- pbe_passno -->
    <xsl:if test="not(pbe_passno)">
       <xsl:if test="every $component in component
                        satisfies boolean($component/pbe_passno)">
          <pbe_passno>
              <xsl:value-of select="max(component/pbe_passno)"/>
          </pbe_passno>
       </xsl:if>
    </xsl:if>

  </xsl:copy>
</xsl:template>

<xsl:template match="identity" mode="recursive_xpath_enrichment">
  <xsl:copy>
    <xsl:apply-templates mode="recursive_xpath_enrichment"/>

    <!-- xpath_evaluate -->
    <xsl:if test="not(xpath_evaluate)">
      <xpath_evaluate>
        <xsl:text>.</xsl:text>
      </xpath_evaluate>
    </xsl:if>

    <!-- xpath_evaluate_inverse -->
    <xsl:if test="not(xpath_evaluate_inverse)">
      <xpath_evaluate_inverse>
        <xsl:text>.</xsl:text>
      </xpath_evaluate_inverse>
    </xsl:if>

    <!-- pbe_passno -->
    <xsl:if test="not(pbe_passno)">
       <xsl:if test="fix">
          <pbe_passno>
                  <xsl:value-of select="0"/>
          </pbe_passno>
       </xsl:if>
    </xsl:if>

  </xsl:copy>
</xsl:template>

<xsl:template name="component" match="component" mode="explicit">

  <!-- xpath_evaluate -->
  <xsl:if test="not(xpath_evaluate)"> 
    <xsl:if test="key('AllRelationshipBySrcTypeAndName',era:packArray((src,rel)))/xpath_evaluate">  <!-- CR-18032 -->
      <xpath_evaluate>
        <xsl:value-of select="key('AllRelationshipBySrcTypeAndName',era:packArray((src,rel)))/xpath_evaluate"/>  <!-- CR-18032 -->
      </xpath_evaluate>
    </xsl:if>
  </xsl:if>

  <!-- xpath_evaluate_inverse -->
  <xsl:if test="not(xpath_evaluate_inverse)
                    and key('AllRelationshipBySrcTypeAndName',era:packArray((src,rel)))/xpath_evaluate_inverse">
    <xpath_evaluate_inverse>
        <xsl:value-of select="key('AllRelationshipBySrcTypeAndName',era:packArray((src,rel)))/xpath_evaluate_inverse"/> 
    </xpath_evaluate_inverse>
  </xsl:if>

  <!-- pbe_passno -->
    <xsl:if test="not(pbe_passno)">
       <xsl:if test="key('AllRelationshipBySrcTypeAndName',era:packArray((src,rel)))/pbe_passno">  
         <pbe_passno>
             <xsl:value-of select="key('AllRelationshipBySrcTypeAndName',era:packArray((src,rel)))/pbe_passno"/> 
         </pbe_passno>
       </xsl:if>
    </xsl:if>

</xsl:template>

<xsl:template match="component" mode="recursive_xpath_enrichment">
  <xsl:copy>
    <xsl:apply-templates mode="recursive_xpath_enrichment"/>
    <xsl:call-template name="component"/>
  </xsl:copy>
</xsl:template>

<xsl:function name="era:combineKey">
  <xsl:param name="element1" as="xs:string"/>
  <xsl:param name="element2" as="xs:string"/>
  <xsl:choose>
    <xsl:when test="$element1 != '' and $element2 != ''">
      <xsl:text>era:packArray((</xsl:text>
      <xsl:value-of select="$element1"/>
      <xsl:text>,</xsl:text>
      <xsl:value-of select="$element2"/>
      <xsl:text>))</xsl:text>
    </xsl:when>
    <xsl:when test="$element1 != ''">
      <xsl:value-of select="$element1"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$element2"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:template match="riser/component|riser/*/component" mode="recursive_xpath_enrichment">
  <xsl:copy>
    <xsl:apply-templates mode="recursive_xpath_enrichment"/>
    <xsl:call-template name="component"/>
    <!-- xpath_delta_key -->
    <xsl:if test="not(xpath_delta_key)">
      <xsl:message>Still thinking </xsl:message>
      <xsl:choose>
        <xsl:when test="not(following-sibling::component)">
          <xsl:message>no next component </xsl:message>
          <xpath_delta_key>
          </xpath_delta_key>
        </xsl:when>
        <xsl:when test="following-sibling::component/identification_status='NotIdentifying'">
          <xsl:message>next component not identifying</xsl:message>
          <xpath_delta_key>
          </xpath_delta_key>
        </xsl:when>
        <xsl:when test="following-sibling::component[1]/xpath_delta_key">
          <xsl:message>next component has xpath_local_key</xsl:message>
          <xsl:if test="key('EntityTypes',dest)/xpath_local_key
                              and xpath_evaluate
                            ">
            <xpath_delta_key>
              <xsl:message>On the money</xsl:message>
              <xsl:value-of select="concat(xpath_evaluate,
                                                   '/',
                                                   era:combineKey(
                                                     following-sibling::component[1]/xpath_delta_key,
                                                     key('EntityTypes',dest)/xpath_local_key
                                                                  )
                                                   )
                                           "/>
            </xpath_delta_key>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>Fallen through the cracks rel 
                      '<xsl:value-of select="concat(src,'.',rel)"/>'</xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:copy>
</xsl:template>

</xsl:transform>
<!-- end of file: ERmodel_v1.2/src/ERmodel2.xpath_enrichment.module.xslt--> 

