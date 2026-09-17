# TRAD2026 · Módulo III — Nextflow

## Atividade guiada — Capybara

**Modalidade:** atividade guiada
**Pipeline:** nf-core/ampliseq 2.18.0  
**Dados:** amplicons 16S de microbioma intestinal de capivara · Illumina · paired-end  
**Infraestrutura:** cluster Marvin · execução via SLURM  
**Objetivo:** construir uma execução reprodutível e tornar explícitas as relações entre entradas, parâmetros, infraestrutura, tarefas e resultados.

Nesta atividade guiada, a turma irá reproduzir uma análise de 16S de capivara usando **dados Illumina paired-end**. O objetivo é tornar visível a lógica de uma execução reprodutível com Nextflow: organizar os diretórios, construir e validar a folha de amostras, reutilizar metadados e parâmetros já preparados, submeter o pipeline via SLURM, acompanhar a execução e inspecionar os resultados.

> **Importante:** Nesta atividade, cada usuário trabalha em seu próprio diretório local dentro do HPC Marvin:
> 
> ```text
> /scratch/$USER
> ```

Para acessar o /scratch/$USER é necessário entrar dentro do HPC do Marvin, e posteriomente fazer um acesso ao:

> 
> ```text
> ssh dgpu01 #se você pertencer ao grupo 01-03
> ssh dgpu02 #se você pertencer ao grupo 04-06
> ssh dgpu03 #se você pertencer ao grupo 07-08
> ```

> Os arquivos de configuração do treinamento permanecem compartilhados em:
>
> ```text
> /scratch/nf-work/profiles/
> ```


> **Relação entre os roteiros:** esta é a atividade guiada de referência. Os procedimentos e critérios de validação aprendidos aqui serão reutilizados no exercício prático Waterwaste.
---

## Sumário

1. [Como usar este roteiro](#1-como-usar-este-roteiro)
2. [O conjunto de dados](#2-o-conjunto-de-dados)
3. [Etapa 1 — Acessar o nó e preparar o ambiente](#3-etapa-1--acessar-o-nó-e-preparar-o-ambiente)
4. [Etapa 2 — Construir a folha de amostras](#4-etapa-2--construir-a-folha-de-amostras)
5. [Etapa 3 — Copiar e conferir os metadados](#5-etapa-3--copiar-e-conferir-os-metadados)
6. [Etapa 4 — Copiar e adaptar o arquivo de parâmetros](#6-etapa-4--copiar-e-adaptar-o-arquivo-de-parâmetros)
7. [Etapa 5 — Preparar o script de submissão](#7-etapa-5--preparar-o-script-de-submissão)
8. [Etapa 6 — Submeter e acompanhar](#8-etapa-6--submeter-e-acompanhar)
9. [Etapa 7 — Inspecionar uma tarefa do Nextflow](#9-etapa-7--inspecionar-uma-tarefa-do-nextflow)
10. [Etapa 8 — Ler os resultados](#10-etapa-8--ler-os-resultados)
11. [Checklist e discussão](#11-checklist-e-discussão)

---

# 1. Como usar este roteiro guiado

O objetivo desta atividade não é apenas “rodar um pipeline”. A proposta é acompanhar como uma análise é organizada e executada de forma reprodutível.

Ao longo da prática, observe especialmente:

- como os dados de entrada são descritos no `samplesheet.csv`;
- como o Nextflow separa o diretório da execução do diretório de trabalho;
- como cada processo do pipeline vira uma tarefa independente;
- como o SLURM distribui essas tarefas;
- como o `-resume` permite retomar uma análise sem refazer etapas já concluídas.

O pipeline utilizado é uma cópia local já preparada para o treinamento:

```text
/shared/training/TRAD2026/pipelines/nf-core-ampliseq-2.18.0
```

Isso evita que todos os participantes precisem baixar o pipeline simultaneamente.

---

# 2. O conjunto de dados

Nesta atividade serão utilizados dados 16S associados ao estudo de microbioma intestinal de capivaras.

Os FASTQs estão disponíveis em:

```text
/shared/training/TRAD2026/raw_data/16S_Hydrochoerus_hydrochaeris
```

Diferentemente da atividade Waterwaste, os dados da Capivara são **paired-end**. Portanto, cada corrida possui dois arquivos:

```text
SRRxxxxxxxx_1.fastq.gz
SRRxxxxxxxx_2.fastq.gz
```

Na folha de amostras, isso exige três colunas:

```text
sample,fastq_1,fastq_2
```

A análise será executada com `nf-core/ampliseq 2.18.0`.

Os parâmetros de amplificação usados na atividade são:

```text
Forward primer (515F): GTGCCAGCMGCCGCGGTAA
Reverse primer (806R): GGACTACHVGGGTWTCTAAT
```

Como o sequenciamento é Illumina, o parâmetro `iontorrent` deve permanecer como:

```json
"iontorrent": false
```

---

# 3. Etapa 1 — Acessar o nó e preparar o ambiente

## 3.1 Acessar o Marvin

Acesse o cluster:

```bash
ssh usuario@marvin.cnpem.br
```

Depois, entre no nó de execução indicado pelo instrutor:

```bash
ssh dgpuXX
```

> **Atenção — distribuição dos grupos**
>
> A distribuição dos grupos da atividade **Capivara** entre `dgpu01`, `dgpu02` e `dgpu03` será informada pelo instrutor antes da execução.
>
> Como `/scratch` é um disco local, o grupo deve permanecer no **mesmo nó** durante toda a atividade.

Confirme o nó:

```bash
hostname
```

---

## 3.2 Carregar o Nextflow e definir as variáveis

```bash
module avail
module load nextflow/26.04.4

export SHARED=/shared/training/TRAD2026
export SCRATCH=/scratch/$USER
export DATASET=Capybara

export NXF_HOME="/scratch/$USER/nfx-home"
export NXF_SINGULARITY_CACHEDIR="$SHARED/containers/nextflow/amplicon"

export NXF_WORK="$SCRATCH/ampliseq/work/$DATASET"
export RUN="$SCRATCH/ampliseq/runs/$DATASET"
export LOGS="$SCRATCH/ampliseq/logs/$DATASET"
export METRICS="$SCRATCH/ampliseq/metrics/$DATASET"

export MARVIN_CONFIG=/scratch/nf-work/profiles/marvin_dgp.config
export AMPLISEQ_CONFIG=/scratch/nf-work/profiles/ampliseq.config
```

Crie os diretórios:

```bash
mkdir -p "$NXF_HOME"
mkdir -p "$NXF_WORK"
mkdir -p "$RUN"
mkdir -p "$LOGS"
mkdir -p "$METRICS"
```

Entre no diretório da execução:

```bash
cd "$RUN"
pwd
```

A saída deve seguir este padrão:

```text
/scratch/<seu_usuario>/ampliseq/runs/Capybara
```

Confira também os arquivos de configuração:

```bash
ls -lh "$MARVIN_CONFIG"
ls -lh "$AMPLISEQ_CONFIG"
```

> **Atenção:** o diretório `logs/` deve existir **antes** do `sbatch`. O SLURM tenta abrir os arquivos de `--output` e `--error` no momento da submissão.

---

## 3.3 Organização dos diretórios

A estrutura principal da atividade será:

```text
/scratch/$USER/
├── nfx-home/
└── ampliseq/
    ├── runs/
    │   └── Capybara/
    │       ├── samplesheet.csv
    │       ├── metadata.tsv
    │       ├── Capybara_grupoX.json
    │       └── results/
    ├── work/
    │   └── Capybara/
    ├── logs/
    │   └── Capybara/
    └── metrics/
        └── Capybara/
```

Os arquivos de configuração **não** ficam dentro do diretório individual. Eles são compartilhados:

```text
/scratch/nf-work/profiles/marvin_dgp.config
/scratch/nf-work/profiles/ampliseq.config
```

---

# 4. Etapa 2 — Construir a folha de amostras

O `samplesheet.csv` informa ao pipeline quais arquivos FASTQ pertencem a cada corrida.

Como os dados são paired-end, vamos associar automaticamente cada arquivo `_1.fastq.gz` ao respectivo `_2.fastq.gz`.

## 4.1 Declarar os caminhos

```bash
DATA=/shared/training/TRAD2026/raw_data/16S_Hydrochoerus_hydrochaeris
SAMPLESHEET="$RUN/samplesheet.csv"
```

Crie o cabeçalho:

```bash
printf "sample,fastq_1,fastq_2\n" > "$SAMPLESHEET"
```

Popule o arquivo:

```bash
find "$DATA" -maxdepth 1 -type f -name "*_1.fastq.gz" | sort | while read -r r1; do r2="${r1/_1.fastq.gz/_2.fastq.gz}"; sample=$(basename "$r1" | grep -oE 'SRR[0-9]+' | head -n1); if [[ -f "$r2" ]]; then printf "%s,%s,%s\n" "$sample" "$r1" "$r2"; else echo "[WARNING] R2 não encontrado para $sample: $r2" >&2; fi; done >> "$SAMPLESHEET"
```

Visualize:

```bash
column -s, -t < "$SAMPLESHEET" | head
```

---

## 4.2 Validar a folha de amostras

Conte os arquivos R1:

```bash
find "$DATA" -maxdepth 1 -type f -name "*_1.fastq.gz" | wc -l
```

Conte os arquivos R2:

```bash
find "$DATA" -maxdepth 1 -type f -name "*_2.fastq.gz" | wc -l
```

Conte as amostras declaradas no samplesheet:

```bash
tail -n +2 "$SAMPLESHEET" | wc -l
```

Os três valores devem ser compatíveis.

Verifique se algum identificador aparece mais de uma vez:

```bash
cut -d',' -f1 "$SAMPLESHEET" | tail -n +2 | sort | uniq -d
```

O comando não deve imprimir nada.

Verifique se todos os FASTQs declarados existem:

```bash
awk -F',' 'NR>1 {print $2; print $3}' "$SAMPLESHEET" | while read -r fq; do [[ -f "$fq" ]] || echo "AUSENTE: $fq"; done
```

Novamente, a saída deve permanecer vazia.

> **Importante:** nesta etapa estamos usando o identificador `SRR` como identificador da corrida no `samplesheet`. A relação entre corrida e amostra biológica deve ser interpretada a partir do desenho experimental e do `metadata.tsv`.

---

# 5. Etapa 3 — Copiar e conferir os metadados

Nesta atividade, o `metadata.tsv` já foi preparado previamente. Em vez de reconstruí-lo do zero, vamos copiar a versão de referência e inspecioná-la.

Defina o diretório de referência:

```bash
REF_RUN=/scratch/nf-work/runs/ampliseq/Capybara/grupoX
```

Copie o metadata:

```bash
cp "$REF_RUN/metadata.tsv" "$RUN/metadata.tsv"
```

Confira:

```bash
ls -lh "$RUN/metadata.tsv"
```

Visualize o início:

```bash
column -t -s $'\t' "$RUN/metadata.tsv" | head
```

Confira o cabeçalho:

```bash
head -n1 "$RUN/metadata.tsv"
```

Conte as linhas:

```bash
wc -l "$RUN/metadata.tsv"
```

---

## 5.1 Comparar os identificadores

Liste os identificadores do samplesheet:

```bash
cut -d',' -f1 "$SAMPLESHEET" | tail -n +2 | sort -u > "$RUN/samplesheet_ids.txt"
```

Liste os identificadores da primeira coluna do metadata:

```bash
cut -f1 "$RUN/metadata.tsv" | tail -n +2 | sort -u > "$RUN/metadata_ids.txt"
```

Compare:

```bash
comm -3 "$RUN/samplesheet_ids.txt" "$RUN/metadata_ids.txt"
```

Se os dois arquivos usam exatamente o mesmo nível de identificação, a saída deve ser vazia.

> **Atenção:** na Capivara, corrida de sequenciamento e amostra biológica não devem ser assumidas automaticamente como equivalentes. Se o `comm` retornar diferenças, primeiro verifique o desenho experimental e a estrutura do metadata antes de modificar qualquer arquivo.

---

# 6. Etapa 4 — Copiar e adaptar o arquivo de parâmetros

O arquivo JSON de referência também já está preparado.

Copie:

```bash
cp "$REF_RUN/Capybara_grupoX.json" "$RUN/Capybara_grupoX.json"
```

Como arquivos JSON não expandem automaticamente `$USER`, substitua o caminho da execução de referência pelo diretório individual do usuário:

```bash
sed -i "s|/scratch/nf-work/runs/ampliseq/Capybara/grupoX|$RUN|g" "$RUN/Capybara_grupoX.json"
```

Visualize:

```bash
cat "$RUN/Capybara_grupoX.json"
```

Valide a sintaxe:

```bash
python3 -m json.tool "$RUN/Capybara_grupoX.json" > /dev/null && echo "JSON OK"
```

Confira os parâmetros principais:

```bash
grep -E '"(input|metadata|outdir|FW_primer|RV_primer|iontorrent)"' "$RUN/Capybara_grupoX.json"
```

A configuração deve apontar para os arquivos do próprio usuário e conter, entre os parâmetros da atividade:

```text
FW_primer = GTGCCAGCMGCCGCGGTAA
RV_primer = GGACTACHVGGGTWTCTAAT
iontorrent = false
```

---

# 7. Etapa 5 — Preparar o script de submissão

Crie o arquivo:

```bash
vim "$RUN/submit_ampliseq_capybara.sh"
```

Cole o conteúdo abaixo.

> **Antes de submeter:** substitua `dgpuXX` pelo nó designado para seu grupo.

```bash
#!/bin/bash

#SBATCH --job-name=ampliseq_capybara
#SBATCH --partition=gui
#SBATCH --nodelist=dgpuXX
#SBATCH --output=/scratch/%u/ampliseq/logs/Capybara/slurm-%j.out
#SBATCH --error=/scratch/%u/ampliseq/logs/Capybara/slurm-%j.err
#SBATCH --cpus-per-task=2
#SBATCH --mem=2G
#SBATCH --time=08:00:00

set -euo pipefail

module load nextflow/26.04.4

SHARED=/shared/training/TRAD2026
SCRATCH=/scratch/$USER
DATASET=Capybara

MARVIN_CONFIG=/scratch/nf-work/profiles/marvin_dgp.config
AMPLISEQ_CONFIG=/scratch/nf-work/profiles/ampliseq.config

# --- Containers -----------------------------------------------------

export NXF_SINGULARITY_CACHEDIR="$SHARED/containers/nextflow/amplicon"

export SINGULARITY_TMPDIR="$SCRATCH/tmp/singularity/${SLURM_JOB_ID}"
export APPTAINER_TMPDIR="$SINGULARITY_TMPDIR"

mkdir -p "$SINGULARITY_TMPDIR"

# --- Limpeza do temporário -----------------------------------------

cleanup() {
    rm -rf "$SINGULARITY_TMPDIR"
}

trap cleanup EXIT

# --- Nextflow home --------------------------------------------------

export NXF_HOME="$SCRATCH/nfx-home"
export NXF_OPTS="-Xms512m -Xmx1536m"

mkdir -p "$NXF_HOME"

# --- Credencial do GitHub, quando existir --------------------------

if [[ -f "$HOME/.nextflow/scm" ]]; then
    cp "$HOME/.nextflow/scm" "$NXF_HOME/scm"
    chmod 600 "$NXF_HOME/scm"
fi

# --- Diretórios da execução ----------------------------------------

RUN="$SCRATCH/ampliseq/runs/$DATASET"
WORK="$SCRATCH/ampliseq/work/$DATASET"
LOGS="$SCRATCH/ampliseq/logs/$DATASET"
METRICS="$SCRATCH/ampliseq/metrics/$DATASET"

PARAMS="$RUN/Capybara_grupoX.json"

mkdir -p "$RUN"
mkdir -p "$WORK"
mkdir -p "$LOGS"
mkdir -p "$METRICS"

cd "$RUN"

# --- Execução -------------------------------------------------------

nextflow \
    -log "$LOGS/nextflow_${SLURM_JOB_ID}.log" \
    run "$SHARED/pipelines/nf-core-ampliseq-2.18.0" \
    -profile singularity \
    -c "$MARVIN_CONFIG" \
    -c "$AMPLISEQ_CONFIG" \
    -params-file "$PARAMS" \
    -work-dir "$WORK" \
    -with-report "$METRICS/report_${SLURM_JOB_ID}.html" \
    -with-timeline "$METRICS/timeline_${SLURM_JOB_ID}.html" \
    -with-trace "$METRICS/trace_${SLURM_JOB_ID}.tsv" \
    -resume
```

---

## 7.1 Conferir o script antes de submeter

Valide a sintaxe Bash:

```bash
bash -n "$RUN/submit_ampliseq_capybara.sh" && echo "SCRIPT OK"
```

Confirme o nó configurado:

```bash
grep -- '--nodelist' "$RUN/submit_ampliseq_capybara.sh"
```

Confirme os configs:

```bash
grep '_CONFIG=' "$RUN/submit_ampliseq_capybara.sh"
```

Confira se não há espaços após barras invertidas:

```bash
grep -n '\\[[:space:]]\+$' "$RUN/submit_ampliseq_capybara.sh"
```

Esse último comando **não deve retornar nada**.

> A barra invertida (`\`) precisa ser o último caractere da linha. Um espaço depois dela quebra a continuação do comando.

---

# 8. Etapa 6 — Submeter e acompanhar

Garanta novamente que o diretório de logs existe:

```bash
mkdir -p "$LOGS"
```

Submeta:

```bash
cd "$RUN"
sbatch submit_ampliseq_capybara.sh
```

O SLURM retornará um identificador:

```text
Submitted batch job JOBID
```

Acompanhe a fila:

```bash
squeue -u "$USER"
```

Ou com mais detalhes:

```bash
squeue -u "$USER" -o "%.18i %.35j %.10T %.12M %.15R"
```

Acompanhe o arquivo de saída:

```bash
tail -f "$LOGS"/slurm-JOBID.out
```

Para sair do `tail -f` sem cancelar o pipeline:

```text
Ctrl+C
```

Para cancelar de fato:

```bash
scancel JOBID
```

> Não apague o diretório `$NXF_WORK` após um cancelamento. Ele contém o cache necessário para o `-resume`.

---

## 8.1 O que observar no log

Quando o pipeline começar a executar tarefas, procure por linhas semelhantes a:

```text
executor > slurm
```

Isso confirma que o Nextflow está usando o SLURM para executar os processos.

Também aparecerão tarefas com hashes, por exemplo:

```text
[8c/1a4f2e] NFCORE_AMPLISEQ:AMPLISEQ:FASTQC ...
```

O código entre colchetes identifica a pasta correspondente dentro do diretório de trabalho.

---

# 9. Etapa 7 — Inspecionar uma tarefa do Nextflow

Escolha um hash mostrado no log e localize a pasta correspondente.

Por exemplo:

```bash
cd "$NXF_WORK"/8c/1a4f2e*
```

Liste os arquivos ocultos:

```bash
ls -lah
```

Você poderá encontrar arquivos como:

```text
.command.run
.command.sh
.command.out
.command.err
.exitcode
```

Visualize o comando executado:

```bash
cat .command.sh
```

Confira o código de saída:

```bash
cat .exitcode
```

Quando o valor for:

```text
0
```

a tarefa terminou com sucesso.

Como os dados da Capivara são paired-end, tarefas que recebem os FASTQs da amostra podem apresentar dois arquivos de entrada associados ao mesmo SRR:

```text
SRRxxxxxxxx_1.fastq.gz
SRRxxxxxxxx_2.fastq.gz
```

O Nextflow normalmente cria links para os arquivos de entrada dentro do work directory, em vez de duplicar fisicamente todos os FASTQs.

---

# 10. Etapa 8 — Ler os resultados

Quando a execução terminar, retorne ao diretório principal:

```bash
cd "$RUN"
```

Liste os resultados:

```bash
ls -lah results/
```

Explore os principais diretórios:

```bash
find results -maxdepth 1 -mindepth 1 -type d -printf '%f\n' | sort
```

Procure o resumo geral:

```bash
ls -lh results/overall_summary.tsv
```

Se disponível, visualize:

```bash
column -t results/overall_summary.tsv | head
```

Também confira os relatórios produzidos pelo pipeline:

```bash
find results -maxdepth 2 -type f \( -name "*.html" -o -name "*.qzv" \) | head -30
```

No diretório de métricas da execução, confira:

```bash
ls -lh "$METRICS"
```

Você deverá encontrar arquivos como:

```text
report_JOBID.html
timeline_JOBID.html
trace_JOBID.tsv
```

Esses arquivos ajudam a entender consumo de recursos, duração das tarefas e paralelização do workflow.

---

# 11. Checklist e discussão

Antes de considerar a atividade concluída, confira:

- [ ] Estou no nó de execução correto.
- [ ] `SCRATCH` aponta para `/scratch/$USER`.
- [ ] `NXF_HOME` aponta para `/scratch/$USER/nfx-home`.
- [ ] O cache de containers aponta para `/shared/training/TRAD2026/containers/nextflow/amplicon`.
- [ ] Os configs usados são `/scratch/nf-work/profiles/marvin_dgp.config` e `/scratch/nf-work/profiles/ampliseq.config`.
- [ ] O `samplesheet.csv` possui as colunas `sample,fastq_1,fastq_2`.
- [ ] A quantidade de R1 e R2 é compatível.
- [ ] Todos os FASTQs declarados no samplesheet existem.
- [ ] O `metadata.tsv` foi copiado da referência.
- [ ] O JSON foi copiado da referência e adaptado para o `$RUN` do usuário.
- [ ] O JSON passou em `python3 -m json.tool`.
- [ ] O JSON contém `iontorrent: false`.
- [ ] O script passou em `bash -n`.
- [ ] `dgpuXX` foi substituído pelo nó correto antes do `sbatch`.
- [ ] O diretório `logs/` já existia antes da submissão.
- [ ] O log mostra `executor > slurm`.
- [ ] O diretório `$NXF_WORK` foi preservado para permitir `-resume`.

---

## Perguntas para discussão

1. Por que a folha de amostras da Capivara possui uma coluna a mais do que a da Waterwaste?
2. O que diferencia uma corrida de sequenciamento de uma amostra biológica?
3. Por que não devemos assumir que cada SRR corresponde necessariamente a uma unidade biológica independente?
4. O que o diretório `work/` armazena e por que ele é importante para o `-resume`?
5. Por que o `/scratch` local exige que uma execução permaneça associada ao nó correto?
6. Qual é a diferença entre o job que executa o Nextflow e as tarefas individuais submetidas ao SLURM?
7. Em qual etapa ocorreu a maior perda de leituras?
8. As curvas de rarefação sugerem profundidade suficiente?
9. As amostras se agrupam de acordo com as categorias descritas no metadata?
10. Quais etapas da análise deveriam ser revisadas antes de interpretar diferenças biológicas entre grupos?

---

## Caminhos utilizados nesta atividade

| Recurso | Caminho |
|---|---|
| Dados brutos | `/shared/training/TRAD2026/raw_data/16S_Hydrochoerus_hydrochaeris` |
| Pipeline | `/shared/training/TRAD2026/pipelines/nf-core-ampliseq-2.18.0` |
| Containers | `/shared/training/TRAD2026/containers/nextflow/amplicon` |
| Área individual | `/scratch/$USER` |
| Nextflow home | `/scratch/$USER/nfx-home` |
| Run | `/scratch/$USER/ampliseq/runs/Capybara` |
| Work | `/scratch/$USER/ampliseq/work/Capybara` |
| Logs | `/scratch/$USER/ampliseq/logs/Capybara` |
| Metrics | `/scratch/$USER/ampliseq/metrics/Capybara` |
| Config Marvin | `/scratch/nf-work/profiles/marvin_dgp.config` |
| Config ampliseq | `/scratch/nf-work/profiles/ampliseq.config` |
| Metadata de referência | `/scratch/nf-work/runs/ampliseq/Capybara/grupoX/metadata.tsv` |
| JSON de referência | `/scratch/nf-work/runs/ampliseq/Capybara/grupoX/Capybara_grupoX.json` |

---

### Ponto a definir antes da aula

Apenas a **distribuição dos grupos da Capivara entre `dgpu01`, `dgpu02` e `dgpu03`** ainda precisa ser inserida neste roteiro. O restante da estrutura já está preparado para uso individual via `$USER`.
