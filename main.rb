require 'rubygems'
require 'active_record'
require './models/discente.rb'
require './models/docente.rb'
require './models/disciplina.rb'
require './models/identidade.rb'

ActiveRecord::Base.establish_connection :adapter => "sqlite3",
                                        :database => "database.sqlite3"

# Enum de comandos possíveis
$commands = {
  "insere"  => 0,
  "altera"  => 1,
  "deleta"  => 2,
  "procura" => 3,
  "imprime" => 4,
  "tabelas" => 5,
  "sair"    => 6
}

# Hash para facilitar escolha das tabelas pela linha de comando
$tables = {
    "discentes"   => Discente,
    "docentes"    => Docente,
    "disciplinas" => Disciplina,
    "identidades" => Identidade,
    "discente"   => Discente,
    "docente"    => Docente,
    "disciplina" => Disciplina,
    "identidade" => Identidade,
    "Discente"   => Discente,
    "Docente"    => Docente,
    "Disciplina" => Disciplina,
    "Identidade" => Identidade,
    "discentes_disciplinas" => "discentes_disciplinas"
  }

def insert(table, params)
  if table["_"]
    insert_relation(table, params)
    return
  end
  entry = $tables[table].new(params)
  entry.save
  puts("-"*45)
  puts("Nova linha:")
  puts(entry.inspect)
  puts("-"*45)
end


def insert_relation(table, params)
  table = table.split("_")
  table_1 = table[0].chop
  table_2 = table[1].chop
  object_1 = $tables["#{table_1}s"].find(params["#{table_2}_id"])
  object_2 = $tables["#{table_2}s"].find(params["#{table_1}_id"])

  if (table_2 == "disciplina")
   object_1.disciplinas << object_2
  elsif (table_1 == "disciplina")
    object_2.disciplinas << object_1
  end
end


def edit(table, params)
  t = $tables[table]
  if (not t.find(params["id"]))
    puts("# ERRO AO DELETAR: Registro não encontrado")
    return
  end
  entry = t.find(params["id"])
  for p in params
    entry[p[0]] = p[1]
  end
  entry.save
  puts("-"*45)
  puts("Linha alterada:")
  puts(entry.inspect)
  puts("-"*45)
end


def delete(table, params)
  if ($tables[table].all.count == 0)
    puts("# ERRO AO DELETAR: Coluna vazia")
    return
  end
  entry = $tables[table].find(params["id"])
  entry.destroy
  puts("-"*45)
  puts("Linha deletada:")
  puts(entry.inspect)
  puts("-"*45)
end


def find(table, params)
  results = $tables[table]
  for i in 0..params.length-1 do
    if params.keys[i] == "id"
      results = results.find(params["id"])
    else
      results = results.where(params)
    end
  end
  puts("-"*45)
  puts("Resultados:")
  results.each{|r|
    puts(r.inspect)
  }
  puts("-"*45)
end


def print_table(table)
  if table["_"]
    puts("# ERRO: Impossível imprimir tabela de relação n:n")
    return
  end
  puts("-" * 45)
  t = $tables[table]
  puts("Tabela #{t.name}:")

  for c in t.columns do
    puts("- #{c.name}: #{c.type}")  
  end

  puts()
  if t.all.blank?
    puts("< tabela vazia >")
  end
  t.all.each {|entry|
    puts(entry.inspect)
  }
  puts("-" * 45)
end


def print_entry(table, params)
  t = $tables[table]
  entry = t.find(params["id"])
  puts("-" * 45)
  puts("Linha #{params["id"]} da tabela #{t.name}:")
  puts(entry.inspect)
  puts("-" * 45)
end


def print_tables()
  puts("-" * 45)
  puts("Tabelas:")
  puts(ActiveRecord::Base.connection.tables.map{|t| "- #{t}"})
  puts("-" * 45)
end


def parseParams(paramsString)
  params = paramsString.split(";").map{|p|
    k, v = p.split(":", 2)
    k = k.strip
    v = v.strip

    # Se a entrada for "123abc", converte na string 123abc
    if ([v[-1], v[0]] == ['"', '"'])
      v = v[/".*"/].gsub('"', '')
    # Se a entrada iniciar com uma letra, deixa como string
    elsif v[/[a-zA-Z].*/]
    # Se tiver um ".", tipa para float
    elsif v[/\d*\.\d+/]
      v = v.to_f
    # Se for número, tipa para integer
    elsif v[/\d+/]
      v = v.to_i
    end

    [k, v]
  }
  params = Hash[*params.flatten]
  return params
end


def checkForIdParam(params)
  if params["id"]
    puts("# ERRO: parâmetros de inserção não podem conter id")
  end
end


# MAIN PROGRAM #

puts("-"*45)
puts("Comandos:")
puts("> tabelas")
puts("  + Lista as tabelas disponíveis")
puts()
puts("> imprime [tabela]")
puts("  + Imprime colunas e conteúdo da tabela")
puts()
puts("> imprime [tabela] id: x")
puts("  + Imprime linha com id x da tabela")
puts()
puts("> insere  [tabela] [params]")
puts("  + Imprime linha com id x da tabela")
puts()
puts("> altera  [tabela] id: x; [params]")
puts("  + Altera o registro de id x")
puts()
puts("> deleta  [tabela] id: x")
puts("  + Deleta o registro de id x")
puts()
puts("> procura [tabela] [params]")
puts("  + Procura o registro com os parâmetros passados")
puts()
puts("> sair")
puts("  + Sai do programa")
puts()
puts("OBS:")
puts("- Params no formato 'chave_1:valor; chave_2:valor'")
puts("- Conteúdo entre aspas é interpretado como string")
puts("-"*45)

while true
  print("$ ")
  input = gets

  if (not input)
    return
  end

  wrongInput = false

  command, table, params = input.chomp.split(" ", 3)
  command = command ? command.strip : command
  table   = table ? table.strip : table
  params  = params ? params.strip : params

  if !command.match(/[a-z]+/)
    puts("# ERRO: Erro de sintaxe no comando")
    wrongInput = true
  end

  if table
    if !$tables.keys.include?(table)
      puts("# ERRO: Tabela inexistente")
      wrongInput = true
    end
    if !table.match(/[a-z]*/)
      puts("# ERRO: Erro de sintaxe no nome da tabela")
      wrongInput = true
    end
  end

  if params
    params = parseParams(params)
  end
  
  if !wrongInput
    case $commands[command]
    when $commands["insere"]
      checkForIdParam(params)
      insert(table, params)
    when $commands["altera"]
      edit(table, params)
    when $commands["deleta"]
      delete(table, params)
    when $commands["procura"]
      find(table, params)
    when $commands["imprime"]
      if params
        print_entry(table, params)
      else
        print_table(table)
      end
    when $commands["tabelas"]
      print_tables()
    when $commands["sair"]
      return
    else
      puts("# ERRO: Comando inválido")
    end
  end
end