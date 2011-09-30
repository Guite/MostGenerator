<?xml version="1.0" encoding="UTF-8"?>
<mspec:mspec xmlns:mspec="http://www.eclipse.org/buckminster/MetaData-1.0" materializer="p2" name="MOST Generator MSPEC" url="most.cquery">
  <mspec:property key="target.os" value="*"/>
  <mspec:property key="target.ws" value="*"/>
  <mspec:property key="target.arch" value="*"/>
  <mspec:mspecNode
        filter="(buckminster.source=true)"
        materializer="workspace"/>
</mspec:mspec>

<!--
  This defines:
    * which cquery file to use
    * which root feature project to download as a starting point for the build
    * how to materialize:
      - as a default materialize to the target platform (materializer="p2")
      - only if source is "true" materialize to the workspace 
-->
