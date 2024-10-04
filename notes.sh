#!/bin/bash

# Arquivo de notas
NOTES_HEADER="$HOME/notes-cli/mds/header.md"
NOTES_FILE="$HOME/notes-cli/notes.md"
ARGS="$HOME/notes-cli/mds/arguments.md"

# Função verifica se o arquivo de notas existe,
# Caso não exista ele irá criar o arquivo notes.md
# Caso exista irá printar na tela o header e o as notas.
function list_notes() {
  if [ ! -f "$NOTES_FILE" ]; then
    echo "Nenhuma nota criada ainda! Para começar: n -a 'Minha Nota'"
    return
  fi
  cat $NOTES_HEADER $NOTES_FILE | glow -
}

# Função gera um id numerico unico para cada nota criada.
# Esse id ajuda no processo de criação edição e exclusão
# de uma nota especifica.
function generate_id() {
  # Verifica se o arquivo está vazio
  if [ ! -s "$NOTES_FILE" ]; then
    echo 1 # Ira gerar o ID 1 se for a primeira nota
  else
    # Incremenda o valor do ultimo id gerado
    # Ex: se tiver 1 ele soma + 1 gerando o 2.
    echo $(($(tail -n 1 "$NOTES_FILE" | cut -d' ' -f1) + 1))
  fi
}

# Função para adicionar uma nova nota
function add_note() {
  local note="$1"

  if [ -z "$note" ]; then
    echo "Descreva sua nota:"
    read -r note
  fi

  local id=$(generate_id)
  echo "$id -> $note" >>"$NOTES_FILE"
  notify-send Notes "Nota criada!"
}

# Função para editar uma nota existente por ID
function edit_note() {
  local id="$1"
  list_notes

  if [ -z "$id" ]; then
    echo "Informe o N° da nota para editar:"
    read -r id
  fi

  # Verifica se a nota existe
  grep -q "^$id " "$NOTES_FILE"
  if [ $? -ne 0 ]; then
    echo "Não encontramos a nota $id"
    return
  fi

  echo "Digite a nova versão da nota:"
  read -r new_note
  sed -i "s/^$id .*/$id - $new_note/" "$NOTES_FILE"
  notify-send Notes "Nota $id editada com sucesso!"
}

# Função para remover uma nota existente por ID
function remove_note() {
  local id="$1"
  list_notes

  if [ -z "$id" ]; then
    echo "Informa o N° da nota que deseja remover:"
    read -r id
  fi

  # Verifica se a nota existe
  grep -q "^$id " "$NOTES_FILE"
  if [ $? -ne 0 ]; then
    echo "Não encontramos a nota $id"
    return
  fi

  sed -i "/^$id /d" "$NOTES_FILE"
  notify-send Notes "Nota $id removida com sucesso!"
}

# Tratamento de parâmetros
case "$1" in
-a | --add)
  add_note "$2"
  ;;
-e | --edit)
  edit_note "$2"
  ;;
-r | --remove)
  remove_note "$2"
  ;;
-l | --list)
  list_notes
  ;;
*)
  echo "Opção inválida!!!"
  glow "$ARGS"
  ;;
esac
