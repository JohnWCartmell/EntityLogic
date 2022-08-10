What is happening here is that we have an entity model in xml in the v1.4 stye.
This has diagram information mixed in with the structural information aboutthe entity model.
We are using the structural information about entity types and relationships, ignoring the diagram information
and attempting to build a diagram in ERmodellingSeries2 format i.e. expressed in terms of enclosures and 
routes.

Use script ../scripts/generate_diagram.bat this invokes the transform ERmodel2.diagram.xslt as folows:
                       ..\scripts\generate_diagram.bat ERmodelERmodel
					   
then process the ERmodelERmodel.diagram.xml that is output
                       ..\scripts\buildExample.bat ERmodelERmodel.diagram.xml
output is ../docs/ERmodelERmodel.diagram.svg

This output is further elaborated, enriched and turned into svg (see docs folder for final svg output).

As part of this development I have changed the elaboration, enrichment, svg transforms to require diagrams be
a diagram namespace. 

August 20121 - I have changed  all other examples by
changing source line xmlns="" to xmlns="http://www.entitymodelling.org/diagram".

TO DO     -- simplify the example by removing the v1 diagramming stuff.
          -- have output file produced in some other folder.
          -- document what the transform does (this will be in the source folder you'd guess.
		  -- try figure out the two options I experimented with which were at two extremes and experiment
                            with a middle way between extremes.
		  -- figure a small additional smart that can be incremental


