#%% Config {{{

KICAD_PRO=$(ls *.kicad_pro )
NAME=$(basename ${KICAD_PRO} .kicad_pro )
KICAD_PCB="./${NAME}.kicad_pcb"
KICAD_SCH="./${NAME}.kicad_sch"
INTERACTIVE_BOM="$HOME/.local/share/kicad/7.0/3rdparty/plugins/org_openscopeproject_InteractiveHtmlBom/generate_interactive_bom.py"


echo "KICAD_PRO = $KICAD_PRO"
echo "KICAD_SCH = $KICAD_SCH"
echo "KICAD_PCB = $KICAD_PCB"
echo "NAME      = $NAME"

#}}}
#%% Clear generated files {{{

rm -rf fab fig
rm ${NAME}-fab.zip
mkdir  fab fig

# }}}
#%% Export schematic {{{

args=(
  -o fig/${NAME}-schematic.pdf
  -t Drawing
  ${KICAD_SCH}
)

kicad-cli sch export pdf ${args[@]}

#}}}
#%% Export Drawing {{{
kicad-cli pcb export pdf ${args[@]}

args=(
  -o fig/${NAME}-drawing.pdf
  -l Edge.Cuts,Dwgs.User,Cmts.User,F.SilkS
  -t Drawing
  --include-border-title
  ${KICAD_PCB}
)

kicad-cli pcb export pdf ${args[@]}

# }}}
#%% Export 3D model {{{

args=(
  # output file
  -o fig/${NAME}.step

  #
  --subst-models

  # overwrite output file
  --force

  # input .kicad_pcb file
  ${KICAD_PCB}
)

kicad-cli pcb export step ${args[@]}

# }}}
#%% Export gerbers {{{

args=(
  # output to fab directory
  -o ./fab

  # Layers
  -l F.Cu,F.Paste,F.SilkS,F.Mask,B.Cu,B.Paste,B.SilkS,B.Mask,Edge.Cuts,In1.Cu,In2.Cu

  # ensure there is no silkscreen on pads
  --subtract-soldermask

  # input .kicad_pcb file
  ${KICAD_PCB}
)

kicad-cli pcb export gerbers ${args[@]}

# }}}
#%% Export drill files {{{

args=(
  # output to fab directory
  -o ./fab/

  # use mm as units
  -u mm

  # generate map file
  --generate-map
  --map-format gerberx2

  # input .kicad_pcb file
  ${KICAD_PCB}
)

kicad-cli pcb export drill ${args[@]}

# }}}
#%% Export Interactive BOM {{{

args=(

  --no-browser

  --dest-dir fab/ibom

  # input .kicad_pcb file
  ${KICAD_PCB}
)

python3 $INTERACTIVE_BOM ${args[@]}

# }}}
#%% Create zip file from fab directory {{{

(cd fab
  zip ../${NAME}-fab.zip ./*
)

# }}}
