#!/bin/bash

# Arquivo de notas
NOTES_FILE="$HOME/notes/notes.md"
ARGS="$HOME/notes/arguments.md"

# Função para exibir o arquivo de notas ou criar se não existir
function show_notes() {
  if [ ! -f "$NOTES_FILE" ]; then
    echo "## Minhas Notas" >"$NOTES_FILE"
  fi
  cat "$NOTES_FILE"
}

# Função para listar as notas usando Glow
function list_notes() {
  if [ ! -f "$NOTES_FILE" ]; then
    echo "Nenhuma nota criada ainda!"
    return
  fi
  glow "$NOTES_FILE"
}

# Função para adicionar uma nova nota
function add_note() {
  echo "Digite a nova nota:"
  read -r note
  echo "- $note" >>"$NOTES_FILE"
  notify-send Notes "Nota adicionada com sucesso!"
}

# Função para editar uma nota existente
function edit_note() {
  show_notes
  echo "Qual nota você deseja editar? (número da nota)"
  read -r note_number
  sed -n "${note_number}p" "$NOTES_FILE" | cut -d' ' -f2-
  echo "Digite a nova versão da nota:"
  read -r new_note
  sed -i "${note_number}s/.*/- $new_note/" "$NOTES_FILE"
  notify-send Notes "Nota $note_number editada com sucesso!"
}

# Função para remover uma nota existente
function remove_note() {
  show_notes
  echo "Qual nota você deseja remover? (número da nota)"
  read -r note_number
  sed -i "${note_number}d" "$NOTES_FILE"
  notify-send Notes "Nota $note_number removida com sucesso!"
}

# Tratamento de parâmetros
case "$1" in
-a | --add)
  add_note
  ;;
-e | --edit)
  edit_note
  ;;
-r | --remove)
  remove_note
  ;;
-l | --list)
  list_notes
  ;;
*)
  echo "Opção invalida!!!"
  glow "$ARGS"
  ;;
esac
