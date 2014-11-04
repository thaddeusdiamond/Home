#####################################
#        ALIASES FOR SCRIPTS        #
#####################################

# Custom delete function
alias del='mv ${*} -t ~/TRASH'

# Suppress output
Quiet() { >/dev/null 2>&1 $* & }

# Find all usages of a given term in a specific directory
GetUsages() { SEARCH_TERM=$1; shift; grep -I -n -R "$SEARCH_TERM" $* | grep -v build/ | grep -v .hg/ | grep -v external-doc/; }

# remove .orig and .rej files kicking around repo
ClearOrigRej() { find . | grep -v .hg/ | grep '\.orig$' | xargs rm; find . | grep '\.rej$' | grep -v .hg/ | xargs rm; }

alias hg_qpatch="hg diff -r qparent > ~/workspace/patch.diff"

function hg_qseries() {
  if [ $# -ne 0 ]; then
    if [ $1 = "--help" ]; then
      echo "Description: View patches in a given queue."
      echo "Usage: hg_qseries [QUEUE_NAME]"
      echo ""
      echo "  QUEUE_NAME      The name of the patch queue. If omitted, the active queue is used."
      return 1
    fi
  fi

  QUEUE=""
  if [ $# -eq 0 ]; then
    QUEUE="`hg qqueue --active`"
  else
    QUEUE=$1
  fi

  PATCH_DIR="`hg root`/.hg/patches-$QUEUE"
  if [ ! -d "$PATCH_DIR" ]; then
    echo "Cannot find patch directory for specified queue: $PATCH_DIR"
    echo ""
    return 1
  fi

  cat $PATCH_DIR/series
}

function hg_qreorder() { 
  if [ $# -ne 0 ]; then
    if [ $1 = "--help" ]; then
      echo "Description: Edit the series file for a given mqueue, usually to reorder patches."
      echo "Usage: hg_qreorder [QUEUE_NAME]"
      echo "  QUEUE_NAME      The name of the patch queue. If omitted, the active queue "
      echo "                  is used."
      echo ""
      return 1
    fi
  fi

  QUEUE=""
  if [ $# -eq 0 ]; then
    QUEUE="`hg qqueue --active`"
    if [ -n "`hg qapplied`" ]; then
      echo "Patches applied; pop all patches first."
      echo ""
      return 1;
    fi
  else
    QUEUE=$1
  fi

  PATCH_DIR="`hg root`/.hg/patches-$QUEUE"
  if [ ! -d "$PATCH_DIR" ]; then
    echo "Cannot find patch directory for specified queue: $PATCH_DIR"
    echo ""
    return 1
  fi

  vi $PATCH_DIR/series
}

function _hg_qcopy() {
  ACTIVE_QUEUE="`hg qqueue --active`"
  if [ $ACTIVE_QUEUE = $2 ]; then
    if [ -n "`hg qapplied`" ]; then
      echo "Patches applied; pop all patches first."
      echo ""
      return 1;
    fi
  fi
  if [ $ACTIVE_QUEUE = $3 ]; then
    if [ -n "`hg qapplied`" ]; then
      echo "Patches applied;  pop all patches first."
      echo ""
      return 1;
    fi
  fi

  PATCH_DIR="`hg root`/.hg/patches"
  PATCH_DIR_SRC="$PATCH_DIR-$2"
  if [ ! -d "$PATCH_DIR_SRC" ]; then
    echo "Cannot find patch directory for specified queue: $PATCH_DIR_SRC"
    echo ""
    return 1
  fi

  PATCH_DIR_DST="$PATCH_DIR-$3"
  if [ ! -d "$PATCH_DIR_DST" ]; then
    echo "Cannot find patch directory for specified queue: $PATCH_DIR_DST"
    echo ""
    return 1
  fi

  PATCH_FILENAME=$1
  PATCH_PATH=$PATCH_DIR_SRC/$PATCH_FILENAME
  if [ ! -f "$PATCH_PATH" ]; then
    echo "Cannot find specified patch file: $PATCH_PATH"
    echo ""
    return 1
  fi

  PATCH_SERIES_DST=$PATCH_DIR_DST/series
  echo $PATCH_FILENAME > $PATCH_SERIES_DST.tmp
  cat $PATCH_SERIES_DST >> $PATCH_SERIES_DST.tmp
  mv $PATCH_SERIES_DST.tmp $PATCH_SERIES_DST

  cp $PATCH_PATH $PATCH_DIR_DST
}

function hg_qcopy() {
  if [ $# -ne 3 ]; then
    echo "Description: Copy a patch file from one queue to another. Note: This will also "
    echo "             update the series file in the destination queue."
    echo "Usage: hg_qcopy PATCH_FILE SRC_QUEUE_NAME DST_QUEUE_NAME"
    echo ""
    return 1
  fi
  
  _hg_qcopy $1 $2 $3
}

function hg_qmove() {
  if [ $# -ne 3 ]; then
    echo "Description: Move a patch file from one queue to another. Note: This will also "
    echo "             update the series file in both queues."
    echo "Usage: hg_qmove PATCH_FILE SRC_QUEUE_NAME DST_QUEUE_NAME"
    echo ""
    return 1
  fi

  _hg_qcopy $1 $2 $3
  RETURN_CODE=$?
  if [ $RETURN_CODE -ne 0 ]; then
    return $RETURN_CODE
  fi
  
  PATCH_SERIES_SRC=$PATCH_DIR_SRC/series
  sed "/`echo $PATCH_FILENAME`/d" $PATCH_SERIES_SRC > $PATCH_SERIES_SRC.tmp
  mv $PATCH_SERIES_SRC.tmp $PATCH_SERIES_SRC

  rm $PATCH_PATH $PATCH_DIR_DST
}

function hg_qexport() {
  if [ $# -ne 3 ]; then
    echo "Description: Export a patch file from a queue to the given directory."
    echo "Usage: hg_qexport PATCH_FILE QUEUE_NAME DST_DIR"
    echo ""
    return 1
  fi
  
  PATCH_DIR="`hg root`/.hg/patches-$2"
  if [ ! -d "$PATCH_DIR" ]; then
    echo "Cannot find patch directory for specified queue: $PATCH_DIR"
    echo ""
    return 1
  fi

  DST_DIR=$3
  if [ ! -d "$DST_DIR" ]; then
    echo "Cannot find specified destination directory: $DST_DIR"
    echo ""
    return 1
  fi

  cp $PATCH_DIR/$1 $DST_DIR
} 


function idea_repo_sync() {
  if [ $# -ne 2 ]; then
    echo "Description: Copy IntelliJ project settings from one local repo to another.     "
    echo "             This will update any paths in the setting files as needed.         "
    echo ""   
    echo "             Note: This assumes the repo is located at ~/workspace/REPO_NAME.   "   
    echo ""
    echo ""
    echo "Usage: idea_repo_sync SRC_REPO_NAME DST_REPO_NAME"
    echo ""
    return 1
  fi
    
  SRC_REPO_NAME=$1
  DST_REPO_NAME=$2

  SRC_REPO_ROOT=~/workspace/$SRC_REPO_NAME
  DST_REPO_ROOT=~/workspace/$DST_REPO_NAME
  
  rm    ${DST_REPO_ROOT}/*.iml
  rm -r ${DST_REPO_ROOT}/.idea
  
  scp    ${SRC_REPO_ROOT}/*.iml ${DST_REPO_ROOT}
  scp -r ${SRC_REPO_ROOT}/.idea ${DST_REPO_ROOT}

  sed -i -e "s,$SRC_REPO_NAME,$DST_REPO_NAME,g" ${DST_REPO_ROOT}/.idea/.name
  sed -i -e "s,$SRC_REPO_NAME,$DST_REPO_NAME,g" ${DST_REPO_ROOT}/.idea/*.xml

  mv ${DST_REPO_ROOT}/${SRC_REPO_NAME}.iml ${DST_REPO_ROOT}/${DST_REPO_NAME}.iml
}
