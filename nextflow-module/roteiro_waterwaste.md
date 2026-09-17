# TRAD2026 · Módulo III — Nextflow
## Exercício prático — Waterwaste

**Modalidade:** exercício prático autônomo, realizado em grupo após a atividade guiada  
**Pipeline:** nf-core/ampliseq 2.18.0  
**Dados:** amplicons 16S de águas residuárias · Ion Torrent · single-end  
**Infraestrutura:** cluster Marvin · execução via SLURM  
**Objetivo:** aplicar de forma autônoma o percurso desenvolvido na atividade guiada da Capybara, registrando verificações, decisões, evidências de execução e interpretação inicial dos resultados.


> **Relação entre os roteiros:** este exercício deve ser realizado após a atividade guiada da Capybara. O grupo deve reutilizar a mesma lógica de organização, validação, submissão, monitoramento e inspeção, adaptando-a ao conjunto Waterwaste.

---

## Sumário

- [1. Desafio e resultados esperados](#1-desafio-e-resultados-esperados)
- [2. Materiais disponibilizados para o exercício](#2-materiais-disponibilizados-para-o-exercício)
- [PARTE I — Preparar o ambiente](#parte-i--preparar-o-ambiente)
  - [3. Entrar no Marvin e carregar o Nextflow](#3-entrar-no-marvin-e-carregar-o-nextflow)
  - [4. Declarar as variáveis da atividade](#4-declarar-as-variáveis-da-atividade)
- [PARTE II — Trazer as entradas para a execução](#parte-ii--trazer-as-entradas-para-a-execução)
  - [5. Copiar os arquivos preparados](#5-copiar-os-arquivos-preparados)
  - [6. Inspecionar e validar o `samplesheet.csv`](#6-inspecionar-e-validar-o-samplesheetcsv)
  - [7. Inspecionar e validar o `metadata.tsv`](#7-inspecionar-e-validar-o-metadatatsv)
  - [8. Cruzar `samplesheet.csv` e `metadata.tsv`](#8-cruzar-samplesheetcsv-e-metadatatsv)
  - [9. Inspecionar e validar o arquivo JSON](#9-inspecionar-e-validar-o-arquivo-json)
- [PARTE III — Entender a configuração da infraestrutura](#parte-iii--entender-a-configuração-da-infraestrutura)
  - [10. Conferir os profiles](#10-conferir-os-profiles)
- [PARTE IV — Criar o script de submissão](#parte-iv--criar-o-script-de-submissão)
  - [11. Criar `submit_ampliseq_waterwaste.sh`](#11-criar-submit_ampliseq_waterwastesh)
- [PARTE V — Submeter e observar a orquestração](#parte-v--submeter-e-observar-a-orquestração)
  - [12. Checklist pré-submissão](#12-checklist-pré-submissão)
  - [13. Submeter ao SLURM](#13-submeter-ao-slurm)
  - [14. Acompanhar os logs](#14-acompanhar-os-logs)
- [PARTE VI — Abrir a “caixa-preta” de uma tarefa](#parte-vi--abrir-a-caixa-preta-de-uma-tarefa)
  - [15. Localizar uma tarefa no `work/`](#15-localizar-uma-tarefa-no-work)
- [PARTE VII — Entender `-resume`](#parte-vii--entender--resume)
  - [16. Por que não apagar o `work/` durante a atividade](#16-por-que-não-apagar-o-work-durante-a-atividade)
- [PARTE VIII — Ler os artefatos de execução](#parte-viii--ler-os-artefatos-de-execução)
  - [17. Métricas do Nextflow](#17-métricas-do-nextflow)
  - [18. Resultados do pipeline](#18-resultados-do-pipeline)
- [PARTE IX — Fechamento conceitual](#parte-ix--fechamento-conceitual)
  - [19. Reconstruindo a execução](#19-reconstruindo-a-execução)
  - [20. Checklist final do exercício prático](#20-checklist-final-do-exercício-prático)
- [21. Organização sugerida do trabalho do grupo](#21-organização-sugerida-do-trabalho-do-grupo)
- [22. Comandos de recuperação rápida](#22-comandos-de-recuperação-rápida)
- [23. Entrega e fechamento do exercício](#23-entrega-e-fechamento-do-exercício)

---

## 1. Desafio e resultados esperados

Ao final do exercício, o grupo deverá demonstrar que consegue:

1. distinguir **dados**, **parâmetros**, **configuração de infraestrutura**, **containers**, **work directory** e **resultados**;
2. preparar uma área de execução individual em `/scratch/$USER`;
3. copiar e validar os três arquivos de entrada já preparados para a atividade:
   - `samplesheet.csv`;
   - `metadata.tsv`;
   - `Waterwaste.json`;
4. submeter o `nf-core/ampliseq` ao SLURM usando uma cópia local do pipeline;
5. acompanhar a execução e relacionar processos do Nextflow às tarefas do cluster;
6. reconhecer por que `-resume`, o diretório `work/` e o cache de containers são fundamentais para reprodutibilidade e retomada.

> **Entrega central do grupo:** não estamos apenas “rodando um pipeline”. Estamos organizando explicitamente **entradas + parâmetros + software + infraestrutura + execução + resultados**.

---

## 2. Materiais disponibilizados para o exercício

Os FASTQs permanecem no diretório compartilhado do treinamento. Os arquivos auxiliares da atividade serão entregues **já validados**, para que o foco desta aula seja a orquestração com Nextflow.

O grupo receberá, em um único diretório de referência:

```text
samplesheet.csv
metadata.tsv
Waterwaste.json
```

Defina abaixo o caminho real usado na aula:

```bash
export INPUTS_REF="$SHARED/<DIRETORIO_DE_REFERENCIA>/Waterwaste"
```

> **Antes de iniciar:** confirme com o instrutor o valor que substitui `<DIRETORIO_DE_REFERENCIA>` antes de distribuir o roteiro. A partir daí, nenhum estudante precisa editar os arquivos de entrada manualmente.

O pipeline utilizado na atividade é uma cópia local já validada:

```text
/shared/training/TRAD2026/pipelines/nf-core-ampliseq-2.18.0
```

Isso evita depender de download do GitHub durante a aula.

---

# PARTE I — Preparar o ambiente

## 3. Entrar no Marvin e carregar o Nextflow

Acesse o cluster e, para esta demonstração, entre no nó utilizado pela prática:

```bash
ssh usuario@marvin.cnpem.br
ssh dgpu01
```

Confira os módulos e carregue a versão usada no treinamento:

```bash
module avail
module load nextflow/26.04.4
nextflow -version
```

### Pergunta para a turma

> O `module load nextflow` instala o Nextflow no seu usuário ou apenas disponibiliza uma versão já instalada pela infraestrutura?

---

## 4. Declarar as variáveis da atividade

Vamos centralizar os caminhos em variáveis de ambiente. Isso reduz repetição, facilita leitura e torna o roteiro mais portátil.

```bash
export SHARED=/shared/training/TRAD2026
export SCRATCH=/scratch/$USER
export GRUPO=grupoN
export DATASET=Waterwaste

# Diretório com os três arquivos preparados pelo instrutor
export INPUTS_REF="$SHARED/<DIRETORIO_DE_REFERENCIA>/Waterwaste"

# FASTQs originais
export DATA="$SHARED/raw_data/16S_Waterwaste"

# Containers: o conjunto compartilhado se chama 'amplicon'
export NXF_SINGULARITY_CACHEDIR="$SHARED/containers/nextflow/amplicon"

# Diretórios individuais da execução
export NXF_WORK="$SCRATCH/ampliseq/work/$DATASET"
export RUN="$SCRATCH/ampliseq/runs/$DATASET"
export LOGS="$SCRATCH/ampliseq/logs/$DATASET"
export METRICS="$SCRATCH/ampliseq/metrics/$DATASET"

# Perfis de execução previamente preparados para o Marvin
export PROFILE_DIR=/scratch/nf-work/profiles
```

Crie a estrutura:

```bash
mkdir -p "$RUN" "$LOGS" "$METRICS" "$NXF_WORK"
cd "$RUN"
pwd
```

O resultado deverá apontar para uma área do seu próprio usuário, por exemplo:

```text
/scratch/seu.usuario/ampliseq/runs/Waterwaste
```

### O que cada diretório representa?

```text
/shared/training/TRAD2026/
├── raw_data/16S_Waterwaste/              dados brutos compartilhados
├── containers/nextflow/amplicon/         containers já disponíveis
└── pipelines/nf-core-ampliseq-2.18.0/    código do pipeline

/scratch/$USER/ampliseq/
├── runs/Waterwaste/                      arquivos que descrevem a execução
├── work/Waterwaste/                      cache das tarefas do Nextflow
├── logs/Waterwaste/                      logs do Nextflow e SLURM
└── metrics/Waterwaste/                   report, timeline e trace
```

> **Ponto didático:** `RUN` descreve a execução; `NXF_WORK` guarda o estado intermediário que permite ao Nextflow retomar tarefas já concluídas.

---

# PARTE II — Trazer as entradas para a execução

## 5. Copiar os arquivos preparados

Nesta versão da atividade, **não vamos construir manualmente o samplesheet, o metadata ou o JSON**. Eles serão copiados do diretório de referência e depois validados pela turma.

Primeiro, confirme o conteúdo da referência:

```bash
ls -lh "$INPUTS_REF"
```

Copie os três arquivos:

```bash
cp "$INPUTS_REF/samplesheet.csv" "$RUN/"
cp "$INPUTS_REF/metadata.tsv" "$RUN/"
cp "$INPUTS_REF/Waterwaste.json" "$RUN/${DATASET}.json"
```

Confira:

```bash
ls -lh "$RUN"
```

Você deverá encontrar pelo menos:

```text
samplesheet.csv
metadata.tsv
Waterwaste.json
```

### Pergunta para a turma

> Por que copiamos os arquivos pequenos que **descrevem a execução**, mas não copiamos todos os FASTQs para o nosso `/scratch`?

**Resposta esperada:** porque os arquivos de configuração precisam pertencer à execução individual, enquanto os dados brutos podem continuar em um local compartilhado e ser referenciados por caminho absoluto.

---

## 6. Inspecionar e validar o `samplesheet.csv`

O conjunto é **single-end**, portanto o samplesheet deve conter apenas:

```text
sample,fastq_1
```

Visualize as primeiras linhas:

```bash
head "$RUN/samplesheet.csv"
column -s, -t "$RUN/samplesheet.csv" | head
```

Conte as linhas:

```bash
wc -l < "$RUN/samplesheet.csv"
```

Para 24 amostras, esperamos:

```text
25
```

Verifique IDs duplicados:

```bash
cut -d',' -f1 "$RUN/samplesheet.csv" \
  | tail -n +2 \
  | sort \
  | uniq -d
```

A saída deve ficar vazia.

Agora confirme que todos os FASTQs declarados realmente existem:

```bash
awk -F',' 'NR>1 {print $2}' "$RUN/samplesheet.csv" |
while read -r fq; do
    [[ -f "$fq" ]] || echo "AUSENTE: $fq"
done
```

Novamente, **nenhuma saída é o resultado esperado**.

### Fixação

> Se o arquivo `samplesheet.csv` estiver correto, mas um caminho apontar para um FASTQ inexistente, em qual camada está o problema: no pipeline, no container, no SLURM ou na entrada?

---

## 7. Inspecionar e validar o `metadata.tsv`

Visualize a tabela:

```bash
column -t -s $'\t' "$RUN/metadata.tsv" | head -15
```

Conte as linhas:

```bash
wc -l < "$RUN/metadata.tsv"
```

Esperamos novamente:

```text
25
```

Confira a distribuição por `sample_type`:

```bash
cut -f2 "$RUN/metadata.tsv" \
  | tail -n +2 \
  | sort \
  | uniq -c
```

O desenho esperado é:

```text
6 hospital_wastewater
6 surface_water
12 urban_wastewater
```

Confira os sítios:

```bash
cut -f3 "$RUN/metadata.tsv" \
  | tail -n +2 \
  | sort \
  | uniq -c
```

Esperamos quatro sítios com seis amostras cada.

---

## 8. Cruzar `samplesheet.csv` e `metadata.tsv`

Agora vamos responder uma pergunta simples, mas essencial:

> **Os dois arquivos estão descrevendo exatamente as mesmas amostras?**

Compare os identificadores:

```bash
comm -3 \
  <(tail -n +2 "$RUN/samplesheet.csv" | cut -d',' -f1 | sort) \
  <(tail -n +2 "$RUN/metadata.tsv"   | cut -f1      | sort)
```

O resultado esperado é **nenhuma linha**.

> **Ponto didático:** o pipeline pode estar sintaticamente correto e ainda assim representar um desenho experimental errado. Validar os IDs antes da execução é parte da reprodutibilidade.

---

## 9. Inspecionar e validar o arquivo JSON

O arquivo de parâmetros será usado pelo Nextflow com `-params-file`.

Visualize de forma legível:

```bash
python3 -m json.tool "$RUN/${DATASET}.json"
```

Valide formalmente:

```bash
python3 -m json.tool "$RUN/${DATASET}.json" > /dev/null && echo "JSON OK"
```

Procure o parâmetro da plataforma:

```bash
grep -n 'iontorrent' "$RUN/${DATASET}.json"
```

Para este conjunto, esperamos que o JSON informe o uso de Ion Torrent.

### Pergunta para a turma

> Qual é a diferença entre `samplesheet.csv` e `Waterwaste.json`?

**Resposta esperada:** o samplesheet descreve **quais dados entram**; o JSON descreve **como o pipeline deve processá-los**.

---

# PARTE III — Entender a configuração da infraestrutura

## 10. Conferir os profiles

O pipeline usará dois arquivos de configuração externos:

```bash
ls -lh "$PROFILE_DIR/marvin_dgp.config" \
       "$PROFILE_DIR/ampliseq.config"
```

Nesta atividade, pense neles em duas camadas:

- `marvin_dgp.config` → descreve **onde e como executar** no cluster;
- `ampliseq.config` → ajusta **recursos de processos específicos** do pipeline.

A ordem importa porque configurações posteriores podem sobrescrever anteriores.

### Pergunta para a turma

> O número de CPUs pedido ao job que executa o Nextflow é necessariamente o mesmo número de CPUs usado por cada processo bioinformático?

**Resposta esperada:** não. O job principal executa o **orquestrador**; cada processo pode solicitar recursos próprios ao SLURM conforme a configuração.

---

# PARTE IV — Criar o script de submissão

## 11. Criar `submit_ampliseq_waterwaste.sh`

No diretório `$RUN`:

```bash
cd "$RUN"
vim submit_ampliseq_waterwaste.sh
```

Cole o conteúdo abaixo:

```bash
#!/bin/bash
#SBATCH --job-name=ampliseq_waterwaste
#SBATCH --partition=gui
#SBATCH --nodelist=dgpu01
#SBATCH --output=/scratch/%u/ampliseq/logs/Waterwaste/slurm-%j.out
#SBATCH --error=/scratch/%u/ampliseq/logs/Waterwaste/slurm-%j.err
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=08:00:00

set -euo pipefail

module load nextflow/26.04.4

SHARED=/shared/training/TRAD2026
SCRATCH=/scratch/$USER
DATASET=Waterwaste
PROFILE_DIR=/scratch/nf-work/profiles

# ------------------------------------------------------------------
# Containers
# ------------------------------------------------------------------
export NXF_SINGULARITY_CACHEDIR="$SHARED/containers/nextflow/amplicon"

export SINGULARITY_TMPDIR="$SCRATCH/tmp/singularity/${SLURM_JOB_ID}"
export APPTAINER_TMPDIR="$SINGULARITY_TMPDIR"
mkdir -p "$SINGULARITY_TMPDIR"

cleanup() {
    rm -rf "$SINGULARITY_TMPDIR"
}
trap cleanup EXIT

# ------------------------------------------------------------------
# Nextflow home e JVM do orquestrador
# ------------------------------------------------------------------
export NXF_HOME="$SCRATCH/nxf-home"
export NXF_OPTS="-Xms512M -Xmx3G"
mkdir -p "$NXF_HOME"

# Copia credencial do GitHub somente se ela existir.
# O pipeline da aula e local; portanto ela nao e requisito para esta pratica.
if [[ -f "$HOME/.nextflow/scm" ]]; then
    cp "$HOME/.nextflow/scm" "$NXF_HOME/scm"
    chmod 600 "$NXF_HOME/scm"
fi

# ------------------------------------------------------------------
# Diretorios da execucao
# ------------------------------------------------------------------
export NXF_WORK="$SCRATCH/ampliseq/work/$DATASET"
RUN="$SCRATCH/ampliseq/runs/$DATASET"
WORK="$NXF_WORK"
LOGS="$SCRATCH/ampliseq/logs/$DATASET"
METRICS="$SCRATCH/ampliseq/metrics/$DATASET"

mkdir -p "$RUN" "$WORK" "$LOGS" "$METRICS"
cd "$RUN"

# ------------------------------------------------------------------
# Execucao
# ------------------------------------------------------------------
nextflow \
    -log "$LOGS/nextflow_${SLURM_JOB_ID}.log" \
    run "$SHARED/pipelines/nf-core-ampliseq-2.18.0" \
    -profile singularity \
    -c "$PROFILE_DIR/marvin_dgp.config" \
    -c "$PROFILE_DIR/ampliseq.config" \
    -params-file "$RUN/${DATASET}.json" \
    -work-dir "$WORK" \
    -with-report "$METRICS/report_${SLURM_JOB_ID}.html" \
    -with-timeline "$METRICS/timeline_${SLURM_JOB_ID}.html" \
    -with-trace "$METRICS/trace_${SLURM_JOB_ID}.tsv" \
    -resume
```

Salve o arquivo e torne-o executável:

```bash
chmod +x submit_ampliseq_waterwaste.sh
```

Valide a sintaxe Bash **sem executar**:

```bash
bash -n submit_ampliseq_waterwaste.sh && echo "SCRIPT OK"
```

### Três pontos para explicar antes do `sbatch`

1. **`%u`** será substituído pelo usuário no caminho dos logs do SLURM.
2. **`%j`** será substituído pelo identificador do job.
3. `NXF_OPTS=-Xmx3G` deixa folga dentro dos `4G` pedidos ao SLURM para o processo Java e demais componentes do job principal.

---

# PARTE V — Submeter e observar a orquestração

## 12. Checklist pré-submissão

Execute:

```bash
cd "$RUN"

ls -lh \
  samplesheet.csv \
  metadata.tsv \
  "${DATASET}.json" \
  submit_ampliseq_waterwaste.sh

ls -lh \
  "$PROFILE_DIR/marvin_dgp.config" \
  "$PROFILE_DIR/ampliseq.config"

ls -ld \
  "$NXF_SINGULARITY_CACHEDIR" \
  "$NXF_WORK" \
  "$LOGS" \
  "$METRICS"
```

Só prossiga se todos os caminhos existirem.

---

## 13. Submeter ao SLURM

```bash
sbatch submit_ampliseq_waterwaste.sh
```

Exemplo:

```text
Submitted batch job 4821501
```

Guarde o número do job:

```bash
export JOBID=4821501
```

Acompanhe a fila:

```bash
squeue -u "$USER"
```

### Pergunta para a turma

> Neste momento, o que o SLURM está executando: o FastQC diretamente ou o processo principal do Nextflow?

**Resposta esperada:** primeiro o SLURM inicia o job do **orquestrador Nextflow**. A partir dele, o Nextflow submete as tarefas do pipeline ao executor configurado.

---

## 14. Acompanhar os logs

Veja a saída do job principal:

```bash
tail -f "$LOGS/slurm-${JOBID}.out"
```

Para sair do `tail -f` sem cancelar a execução:

```text
Ctrl+C
```

Veja também o log detalhado do Nextflow:

```bash
tail -f "$LOGS/nextflow_${JOBID}.log"
```

Procure na tela elementos como:

```text
executor > slurm
FASTQC
CUTADAPT
DADA2
```

### Fixação

Peça à turma para localizar:

- o **executor**;
- um **processo**;
- o número de tarefas já concluídas;
- o hash de uma tarefa, por exemplo `[8c/1a4f2e]`.

---

# PARTE VI — Abrir a “caixa-preta” de uma tarefa

## 15. Localizar uma tarefa no `work/`

Quando um hash aparecer no terminal, use os dois níveis do identificador para entrar no diretório correspondente.

Exemplo:

```bash
cd "$NXF_WORK/8c/1a4f2e"*
ls -la
```

Arquivos típicos:

```text
.command.sh
.command.run
.command.log
.command.err
.exitcode
```

Veja o comando que realmente foi executado:

```bash
cat .command.sh
```

Confira o código de saída:

```bash
cat .exitcode
```

Um valor `0` indica sucesso daquela tarefa.

### Pergunta para a turma

> Onde está o pipeline neste momento: no arquivo `.command.sh`, no código DSL do nf-core ou nos dois?

**Discussão:** o pipeline DSL descreve a lógica; o `.command.sh` mostra a materialização concreta de **uma tarefa específica** daquela lógica.

---

# PARTE VII — Entender `-resume`

## 16. Por que não apagar o `work/` durante a atividade

O diretório:

```bash
$NXF_WORK
```

é o cache de execução do Nextflow.

Se um job for interrompido, podemos reenviar o mesmo script com:

```text
-resume
```

O Nextflow compara as tarefas e reaproveita aquelas cujo contexto continua válido.

### Demonstração opcional do instrutor

Mostre o estado atual:

```bash
nextflow log
```

Se for seguro durante a aula, interrompa uma execução de demonstração e reenvie o script para mostrar tarefas sendo reutilizadas.

> **Mensagem-chave:** `-resume` não é “continuar pela linha seguinte”. É **reutilizar tarefas previamente calculadas e ainda válidas**.

---

# PARTE VIII — Ler os artefatos de execução

## 17. Métricas do Nextflow

Ao longo da execução, confira:

```bash
ls -lh "$METRICS"
```

Esperamos arquivos como:

```text
report_JOBID.html
timeline_JOBID.html
trace_JOBID.tsv
```

Explique a função de cada um:

| Artefato | Pergunta que ajuda a responder |
|---|---|
| `report.html` | Quanto recurso os processos utilizaram? |
| `timeline.html` | Quando e por quanto tempo cada tarefa executou? |
| `trace.tsv` | Qual foi o estado, duração, CPU e memória de cada tarefa? |
| `nextflow_JOBID.log` | Como o Nextflow interpretou e orquestrou a execução? |

---

## 18. Resultados do pipeline

Quando o pipeline terminar, volte ao diretório da execução:

```bash
cd "$RUN"
find . -maxdepth 2 -type d | sort | head -40
```

Se o `outdir` definido no JSON for `results`, explore:

```bash
ls -lh "$RUN/results"
```

Procure os relatórios consolidados e as saídas de controle de qualidade, denoising e diversidade geradas pelo pipeline.

Se existir `overall_summary.tsv`:

```bash
column -t "$RUN/results/overall_summary.tsv" | head
```

### Perguntas para leitura dos resultados

- Quantas leituras entraram no pipeline?
- Em qual etapa ocorreu a maior perda?
- Quantas sequências permaneceram após o denoising?
- Quantos ASVs foram inferidos?
- A profundidade parece suficiente para todas as amostras?
- Os sítios se separam nas análises de diversidade?

---

# PARTE IX — Fechamento conceitual

## 19. Reconstruindo a execução

Ao final, peça à turma para completar oralmente este fluxo:

```text
FASTQs compartilhados
        ↓
samplesheet.csv
        ↓
metadata.tsv + Waterwaste.json
        ↓
nf-core/ampliseq
        ↓
configs do Marvin
        ↓
containers Singularity/Apptainer
        ↓
Nextflow
        ↓
SLURM
        ↓
work/ + logs/ + metrics/ + results/
```

Em seguida, associe cada componente aos quatro pilares trabalhados no TRAD2026:

```text
DADOS       → FASTQs + samplesheet + metadata
CÓDIGO      → nf-core/ampliseq
AMBIENTE    → containers + módulos
EXECUÇÃO    → Nextflow + SLURM + configs + parâmetros
```

---

## 20. Checklist final do exercício prático

- [ ] `nextflow/26.04.4` carregado.
- [ ] `SHARED`, `SCRATCH`, `DATASET`, `RUN`, `NXF_WORK`, `LOGS` e `METRICS` definidos.
- [ ] `samplesheet.csv`, `metadata.tsv` e `Waterwaste.json` copiados para `$RUN`.
- [ ] `samplesheet.csv` possui 25 linhas e nenhum ID duplicado.
- [ ] Todos os FASTQs apontados pelo samplesheet existem.
- [ ] `metadata.tsv` possui 25 linhas.
- [ ] Os IDs do metadata e do samplesheet coincidem.
- [ ] O JSON passou em `python3 -m json.tool`.
- [ ] O parâmetro de Ion Torrent foi conferido.
- [ ] Os dois profiles existem.
- [ ] O script passou em `bash -n`.
- [ ] O diretório de logs existe **antes** do `sbatch`.
- [ ] O job aparece em `squeue`.
- [ ] A turma identificou `executor > slurm` na execução.
- [ ] Pelo menos uma tarefa foi inspecionada dentro de `work/`.
- [ ] `report`, `timeline`, `trace` e log do Nextflow foram localizados.
- [ ] Foi discutido o papel do `-resume`.

---

# 21. Roteiro sugerido para o instrutor

Uma condução de aproximadamente **70–80 minutos** pode funcionar bem:

| Tempo | Bloco | Ênfase |
|---:|---|---|
| 0–10 min | Ambiente e variáveis | separar shared, scratch, run e work |
| 10–25 min | Entradas | copiar, inspecionar e validar os três arquivos |
| 25–35 min | Configuração | JSON, profiles, containers e recursos |
| 35–45 min | Script SLURM | diferença entre orquestrador e tarefas |
| 45–60 min | Execução | `sbatch`, `squeue`, log e executor SLURM |
| 60–70 min | `work/` e `-resume` | abrir uma tarefa e explicar cache |
| 70–80 min | Resultados e fechamento | métricas + conexão com reprodutibilidade |

> Se o pipeline não terminar dentro da aula, projete uma execução previamente concluída para a seção de resultados. O objetivo desta atividade é compreender a **mecânica da orquestração**, não esperar passivamente pela finalização computacional.

---

## 22. Comandos de recuperação rápida

### Voltar para a execução

```bash
cd "$RUN"
```

### Ver jobs

```bash
squeue -u "$USER"
```

### Cancelar um job

```bash
scancel JOBID
```

### Ver o log do SLURM

```bash
tail -f "$LOGS/slurm-JOBID.out"
```

### Ver o log do Nextflow

```bash
tail -f "$LOGS/nextflow_JOBID.log"
```

### Validar o JSON novamente

```bash
python3 -m json.tool "$RUN/${DATASET}.json" > /dev/null && echo OK
```

### Ver as execuções conhecidas pelo Nextflow

```bash
nextflow log
```

### Não fazer durante a atividade

```bash
rm -rf "$NXF_WORK"
```

Apagar `work/` elimina o cache necessário para `-resume`.

---

## 23. Entrega e fechamento do exercício

Conclua o exercício respondendo:

> **“Se eu entregar outro conjunto de dados, quais componentes desta estrutura permanecem e quais precisam mudar?”**

A resposta deve mostrar quais elementos foram reutilizados da atividade guiada e quais precisaram ser adaptados:

- a lógica de **orquestração** permanece;
- o **dataset**, o **samplesheet**, o **metadata** e os **parâmetros** podem mudar;
- os **profiles** continuam representando a infraestrutura;
- o Nextflow continua separando lógica, execução e cache;
- os containers continuam tornando o ambiente computacional explícito e reproduzível.

## 24. Evidências a entregar

Cada grupo deve registrar e apresentar:

- o caminho do diretório `RUN` utilizado;
- `samplesheet.csv`, `metadata.tsv` e `Waterwaste.json` validados;
- o script `submit_ampliseq_waterwaste.sh`;
- o JOBID e um trecho do log contendo `executor > slurm`;
- o caminho de uma tarefa inspecionada em `work/`, com `.command.sh` e `.exitcode`;
- a localização de `report`, `timeline`, `trace` e dos resultados;
- respostas curtas às perguntas de interpretação da Seção 18;
- dificuldades encontradas e como o grupo as diagnosticou.
