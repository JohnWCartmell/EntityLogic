# EntityLogic
An ERmodel based scripting toolset. 

This is a new and more capable development of the [ERScript] concept.

Additional tranformation logic is supported in that 
it features derived attributes supported by an xpath macro language, more expressive derived relationships and rules for structure eleboration.

It includes all the features of ERScript but also enables the auto-generation of ER diagrams from entity model structure. Diagrams are represented using
[DiagrammingByEnrichment](www.github.com/JohnWCartmell/DiagrammingByEnrichment).

### Requirements
* enable diagram-less entity modelling
* optionally enable one or more ER(A) diagrams to present a model or part of a model  
* support automatic generation of an ER diagram from the pure structure of an ER model
	* support user to improve automated presentation
* source xslt transforms as rules represented in xml described by rules entity model
* factor transform logic so that all that can be represented as derivation of entities, relationships and attributes is represented as derivation of entities, relationships and attributes
  * an example of a derived entity would be a foreign key attribute such as currently created in the ERmodel2.physical_enrichment.module.xslt
  * this may be difficult to describe within entity logic 
   * though maybe it can be constructed by pullback which would be quite something wouldn't it?

## Current State
### SubFolder  ERmodel_v2.1/ERmodelxslt
Contains a rudimentary xslt transformations for
* autogeneration of an instance of the diagram model from a diagram-free entity model
  * as at now in August 2022 the input entity model is required to be an instance of ERmodelv1.2 (it is not required to have any diagramming information -- if it has then it should be ignored )
  * I am considering pausing this development so that I can progress the pure entity logic idea and re-source this work using entity logic.
### Way forward
Have a separate EntityLogic repository
* Create this by extracting diagram free parts of ERmodel v1.4.
* For a time the metamodel of ER logic will be described as an instance of ERmodel v1.4. One advantage of this is so that I can have a diagram of this metamodel. 

#### The ERmodel v1.4 meta model
* includes attributes such as xpath_evaluate which are 'filled in' by xslt as part of a build process. Such attributes as these are derived attributes but is not possible to described such attributes in the model. Would like to extend the model to describe such derived attributes.
* already includes derived (constructed) relationships and supports use of constructed relationships in xpath by way of such as the (derived) attribute xpath_evaluate.
* *xpath_evaluate*  
  * assumes existence of keys for entity types (including abstract entity types one would think) 
   * assumes, therefore, use from xslt  
* question: how much work would it be to bootstrap xpath evaluate.
* question: if we do a bootstrap of xpath-evaluate how much freedom do we have in how we use it are we
  * limited to a static enrichment of a model by its derived features, or are we
  * able to include the derivation of attributes and relatuionships in much more comprehensive transformations such as the gemneration of code or of diagrams.  
* we should try and enable 2. for this will not rule out 1. which maybe useful for debugging and for documentation.
* use of the xpath 3.0 xsl:evaluate will ease the number of xslt passes required in the support of derived attributes which have values defined by xpath expressions rather than fine grain model. Example  attribute 'elementName' which is constructed by the ERmodel2.physical transformation in file ERmodel2.initial_enrichment_module.xslt.
