require 'rubygems'
require 'active_record'
require './models/discente.rb'
require './models/docente.rb'
require './models/disciplina.rb'
require './models/identidade.rb'

ActiveRecord::Base.establish_connection :adapter => "sqlite3",
                                        :database => "database.sqlite3"

$commands = {
  "insere"  => 0,
  "altera"  => 1,
  "deleta"  => 2,
  "procura" => 3,
  "imprime" => 4,
  "tabelas" => 5,
  "sair"    => 6
}

$tables = {
    "discentes"   => Discente,
    "docentes"    => Docente,
    "disciplinas" => Disciplina,
    "identidades" => Identidade,
    "Discente"   => Discente,
    "Docente"    => Docente,
    "Disciplina" => Disciplina,
    "Identidade" => Identidade,
    "discentes_disciplinas" => :discentes_disciplinas
  }

$table_ids = {
    "discente"   => "discentes_id",
    "docente"    => "docentes_id",
    "disciplina" => "disciplina_id",
    "identidade" => "identidade_id",
    "Discente"   => "discentes_id",
    "Docente"    => "docentes_id",
    "Disciplina" => "disciplina_id",
    "Identidade" => "identidade_id",
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
  puts()
  disciplina = Disciplina.find(params["disciplina_id"])
  discente = Discente.find(params["discente_id"])
  discente.disciplinas << disciplina
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
  tables = entry.class.reflect_on_all_associations.map(&:name)
  for paramTable in tables
    puts(paramTable.inspect)
    puts(t.attributes)
    # puts($tables[paramTable].find(t[]).inspect)
  end
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

puts("Comandos:")
puts("1 - insere  [tabela] [params]")
puts("2 - altera  [tabela] id: x; [params]")
puts("3 - deleta  [tabela] id: x")
puts("4 - procura [tabela] [params]")
puts("5 - imprime [tabela]")
puts("6 - imprime [tabela] id: x")
puts("7 - tabelas")
puts("8 - sair")
puts("OBS:")
puts("- Params no formato 'chave_1:valor; chave_2:valor'")
puts("- Conteúdo entre aspas é interpretado como string")

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
    when $commands["imprime"]
    when $commands["tabelas"]
      print_tables()
    when $commands["sair"]
      return
    else
      puts("# ERRO: Comando inválido")
    end
  end
end