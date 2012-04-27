#!/bin/bash

# draft                         write a first version to be filled out and polished later
# ghostwrite                    write for someone else
# lexicon                       vocabulary of a person, language, or branch of knowledge

source_composure ()
{
  if [ -z "$EDITOR" ]; then
    export EDITOR=vi
  fi

  if $(tty -s); then  # is this a TTY?
    bind '"\C-j": edit-and-execute-command'
  fi

  cite ()
  {
      about () { :; }
      about creates a new meta keyword for use in your functions
      local keyword=$1
      for keyword in $*; do
          eval "function $keyword { :; }"
      done
  }

  cite about param example

  lastcmd ()
  {
      about displays last command from history
      param none
      echo $(fc -ln -1)
  }

  name ()
  {
    about wraps last command into a new function
    param 1: name to give function
    example $ ls
    example $ name list
    example $ list
    local name=$1
    eval 'function ' $name ' { ' $(lastcmd) '; }'
  }

  pen ()
  {
    about prints function declaration to stdout
    param 1: name of function
    local func=$1
    # trim trailing semicolons generated by declare -f
    declare -f $func | sed  "s/^\(.*\);$/\1/"
  }

  revise ()
  {
      about loads function into editor for revision
      param 1: function name
      example revise myfunction
      pen $1 > /tmp/$1.bash
      $EDITOR /tmp/$1.bash
      eval "$(cat /tmp/$1.bash)"
      rm /tmp/$1.bash
  }

  metafor ()
  {
      about prints function metadata associated with keyword
      param 1: function name
      param 2: meta keyword
      example metafor reference example
      local func=$1 keyword=$2
      pen $func | sed -n "s/^ *$keyword \([^([].*\)$/\1/p"
  }

  reference ()
  {
      about displays help summary for all functions, or help for specific function
      param 1: optional, function name
      example reference
      example reference metafor

      printline ()
      {
          local metadata=$1 lhs=${2:- }

          if [[ -z "$metadata" ]]
          then
              return
          fi

          OLD=$IFS; IFS=$'\n'
          local line
          for line in $metadata
          do
              printf "%-30s%s\n" $lhs $line
          done
          IFS=$OLD
      }

      help ()
      {
          local func=$1

          local about="$(metafor $func about)"
          printline "$about" $func

          local params="$(metafor $func param)"
          if [[ -n "$params" ]]
          then
              echo "parameters:"
              printline "$params"
          fi

          local examples="$(metafor $func example)"
          if [[ -n "$examples" ]]
          then
              echo "examples:"
              printline "$examples"
          fi

          unset printline
      }

      if [[ -n "$1" ]]
      then
          help $1
      else
          for func in $(compgen -A function); do
              local about="$(metafor $func about)"
              printline "$about" $func
          done
      fi

      unset help printline
  }


  alias r='fc -s'
  alias sl='eval sudo $(lastcmd)'

}

install_composure ()
{
  echo 'stay calm. installing composure elements...'

  # find our absolute PATH
  SOURCE="${BASH_SOURCE[0]}"
  while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

  # vim: automatically chmod +x scripts with #! lines
  done_previously () { [ ! -z "$(grep BufWritePost | grep bin | grep chmod)" ]; }

  if ! $(<~/.vimrc done_previously); then
    echo 'vimrc: adding automatic chmod+x for files with shebang (#!) lines...'
    echo 'au BufWritePost * if getline(1) =~ "^#!" | if getline(1) =~ "/bin/" | silent execute "!chmod a+x <afile>" | endif | endif' >> ~/.vimrc
  fi

  # source this file in .bashrc
  done_previously () { [ ! -z "$(grep source | grep $DIR | grep composure)" ]; }

  if ! $(<~/.bashrc done_previously) && ! $(<~/.bash_profile done_previously); then
    echo 'sourcing composure from .bashrc...'
    echo "source $DIR/$(basename $0)" >> ~/.bashrc
  fi

  echo 'composure installed.'
}

if [[ "$BASH_SOURCE" == "$0" ]]; then
  install_composure
else
  source_composure
  unset install_composure source_composure
fi

