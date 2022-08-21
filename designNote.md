###18 August 2022
The real hardcore approach -- the full bootstrap --  is to go full out to change the meta model adding the new constructions we need for derived relationships and attributes, and instantiating these new constructions as we go. The only transform we are using at this point is the svg generator. At this point I might not know how I will generate the xpath but just need to belive that I can do.

Then and only then do we  upgrade initial_enrichment, physical_enrichment and xpath_enrichment
to support the new features.

Finally we write a new xslt generator to replace much of initial_enrichment and xpath_enrichment.

###Earlier on 18 August 2022
Been mulling over design following inspection of the initial enrichment
 for planting parentType attribute of an entity type.
        
 So define

        all_incoming_composition_relationships 
        = (ancestor_or_self::entity_type)/incoming_composition_relationships
        
How to define incoming_composition_relationships?

Note that
incoming_relationships 
is or should be the inverse of type:Relationship -> ENTITY_TYPE
Should maybe have inverse operator or inverse flag on component.
Brings me back to wondering whether component should be renamed.
...or made abstract with follow/singular and inverse as subtypes.

Note that in xpath-enrichment I implement xpath_evaluate_inverse
attribute for navigations. I'll need that and it should already lead me to something like the fragment key('IncomingCompositionRelationships',name)
from the starting code above in the case of a component.
Hmmm Not sure that I am right here. Cant understand code. Worth studying.
Look at the generated EntityLogicModel.hierarchical.xml it is clear that implementation of
xpath_inverse_evaluate is very patchy. First sight it looks ok for dependency relationships
but not OK for reference relationship TypeOfOrogin and not present at all for most relationships.
Think that it can only be optimised for a reference (by myself or otherwise) if a reference is of global scope.

I need a serious think about the modelling of inverse relationships - why do we do it - 
do we need to? Inverse used in metamodel itself as the pair (inverse,inverse_of)
... both reflexively on reference and on constructed_relationship and on-reflexively between composition and dependency (... interesting example of relationship specialisation here, btw)
Only four compositions have inverses. Only four depdendencies (all named ..) in the model. 
However ... the scope of 'component.rel' uses '..' in its riser.
But no such depdency has been modelled. Does this code work anyway
or is the generated xpath_evaluate broken at this point?
BTW: These xpaths get used at least in referential integrity check
so maybe could ould get an example model and start getting rng and ref
integrity check working to test out the code? BTW: I am struck by how a depdency group is a relationship generalisation which is single valued or can be modelled the otherway around as the origin of specialisations. Seems right.  Other design issues related to this. 
        (i) Should there be an implicit abstract entity type called ENTITY which includes the absolute. 
        (ii) Since we have generated progran type
        as this|that|theother in some circumstances should we implicitly or explicitly allow addition entity types X := this|that|theother
        IDL style 
        (iii)There is some different looking code for generating
        reference to absolute|ENTITY_TYPE somewhere (find this) do we need to study relationships whose destinations are mixtures of particulars and singular universals?

One approach to inverses for reference relationships is to suppose
that the inverses are names only not entities. That as part of defintion of a reference relationship or a constructed relationship it can be given a name for the inverse. Followed to the limit dependencies would be primary and compositions simple named as inverses ... which seems weird.
The chromatography analysis record  (car) model has depedencies everywhere except on the annotation entity type which is also the
only entity type having multiple incoming compoition relationships.
Tellingly its single reference relationship has global scope and therefore does not need a dependency to explicitly navigate in its riser diagonal pair.
A working hypothesis at this point is that depedencies are unnecessary. There is a problem naviating up multiple incoming compositions but this hasn't been solved by having depedencies.
Aggregation of inverses of incoming compositions is a good working hypothesis as all that is necessary. This navigation doesn't have an explicit destination type at this point. If we introduce the most abstract of all ENTITY type then we have the option of using that as the type or any more specialised type that is a super type of all destination types i.e. of all source types of incoming compositions.
The other option is maybe  to introduce an implied entity type. In this case for best results we would like to subtype it off the most specialised subtype of all types from which there are incoming composition relatuionships. Does this then give us static type checking? This will become clearer working on the meta model as an example.
Another thread in this design thinking is coming from the auto-diagramming design that kicked me into revisiting derived relationships and attributes i.e. this investigation. The thinking there was that I could abstract from the composition structure a more abstract composition structure and to lay that out first before laying out the refinement. The idea was that this most abstract composition had no nesting. Need draw what this would be like for the current meta-model to see if it works ... it is possible it becomes degenerate.
Looking to see what the current meta model would look like it looks doable. attribute gets grouped with xml because both have xml style.
A group is intoduced for Relationship and initialiser - I can see how 
this will work OK. There is a big change when I introduce value expressions for attributes because these will have compsotions descending to the navigation entity type. Now there will need to be a top level group of Relationship, initialiser and attribute
.. HANG ON IS THAT RIGHT OR ... do ENTITY TYPE and attribute go in a single group and then Relationship and value_expression in a single group and then navigation below.  BOTH POSSIBLE and at least one other possibility beside. There is no single answer so my previous thoughts in context of diagramming have been half-thought. In future meta model meanwhile it is likely that navigation and value-expression will each have depedencies on the other. Think of putting them in a group 
below the rest. 

One possibility... there is an entity type 
        type expression := type | aggregate

        constructed relationship : type_expression
        navigation.src  : type_expression
        navigation.dest : type_expression

BUT what rules are there for static type checking 
        NOT CLEAR TO ME
Condsider for example
        navigation => parent_entity = inverse(incomingcompositions) : initaliser | Relationship
BUT what can I compose this with -- there cannot be an attribute 
or a relationship that I can compose with Hmmm if I had implemented
nested navigation then I could compose with an aggregate but I have not. 
I am going to have to draft relationships to get further in this thinking.

###Summary
1. Introduce subtypes of component

                component ::= follow | inverse

or possibly 

                component := single | many | inverse

2. This enables the removal of dependencies. NO IT DOESN'T THINK RELATIONAL MODEL, FOREIGN KEYS AND ALL
I was going to say that these can be derived either 

   * as inverse of a single incoming composition relationship, or
   * as aggregation of inverses of multiple incoming composition relationships.
     + if such an aggregation is required then it will be necessary to have a type that is general enough to provide a destination type for
       this aggegated inverse relationship. Only time will tell if more expressivity is required. By current thinking would be necessary to support multiple inheritance is we do need more expressivity.
  