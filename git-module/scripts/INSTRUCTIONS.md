# Instrução para execução dos scripts do projeto prático

Este arquivo contém instruções para execução dos scripts do projeto prático de controle de qualidade de dados do módulo de Git do TRAD2026.

O script `run_qc_pipeline.sh` recebe um diretório de entrada com arquivos FASTQ e um diretório para armazenamento dos resultados. O script identifica automaticamente o tipo de leitura dos datasets utilizados no treinamento e executa as etapas de controle de qualidade correspondentes.

## Uso

```bash
$ bash run_qc_pipeline.sh --help
Uso:
  bash run_qc_pipeline.sh [--verify] INPUT_DIR OUTPUT_DIR [READ_TYPE] [DATASET_NAME]

Opcoes:
  --verify   Verifica a integridade gzip dos FASTQ antes do controle de qualidade
  -h, --help Exibe esta ajuda

READ_TYPE:
  auto      Usa o tipo predefinido para os datasets conhecidos (padrao)
  short-pe  Short reads paired-end: FastQC -> fastp -> FastQC -> MultiQC
  short-se  Short reads single-end: FastQC -> MultiQC
  long      Long reads: NanoPlot -> MultiQC

Exemplos:
  bash run_qc_pipeline.sh INPUT_DIR OUTPUT_DIR
  bash run_qc_pipeline.sh --verify INPUT_DIR OUTPUT_DIR
  bash run_qc_pipeline.sh INPUT_DIR OUTPUT_DIR long Novo_dataset

Com srun:
  srun --partition=<particao> --cpus-per-task=8 --mem=16G --time=06:00:00 \
    bash run_qc_pipeline.sh INPUT_DIR OUTPUT_DIR auto
```

## Execução direta com Bash

Para executar um script diretamente no terminal, utilize:

```bash
$ bash run_qc_pipeline.sh --verify /caminho/para/os/dados /caminho/para/resultados
```

> [!CAUTION]
> Não execute análises computacionalmente intensivas diretamente no nó de login do ambiente HPC. 
> O número de CPUs, a quantidade de memória e os demais recursos solicitados podem variar de acordo com o script e a infraestrutura utilizada.

## Execução com `srun` em ambiente HPC

Para executar o pipeline de forma interativa (`srun`) em um nó de computação gerenciado pelo Slurm:

```bash
$ srun --partition <particao> --cpus-per-task 8 --mem 16GB bash run_qc_pipeline.sh /caminho/para/os/dados /caminho/para/os/resultados
```

Substitua:
* `<particao>` pelo nome da partição indicada para a atividade;
* `/caminho/para/os/dados` pelo caminho do diretório que contém os arquivos de entrada; e
* `/caminho/para/os/resultados` pelo caminho do diretório onde os resultados serão armazenados.

## Execução com `sbatch` em ambiente HPC

Para executar o pipeline em lote (`sbatch`) em um nó de computação gerenciado pelo Slurm:

```bash
$ sbatch \
    --job-name=<nome-do-job> \
    --partition=<particao> \
    --cpus-per-task=8 \
    --mem=16G \
    --output=qc-%j.out \
    --error=qc-%j.err \
    --wrap="bash run_qc_pipeline.sh \
        /caminho/para/os/dados \
        /caminho/para/os/resultados"
```

Substitua:
* `<nome-do-job>` pelo nome desejado para o job;
* `<particao>` pelo nome da partição indicada para a atividade;
* `/caminho/para/os/dados` pelo caminho do diretório que contém os arquivos de entrada; e
* `/caminho/para/os/resultados` pelo caminho do diretório onde os resultados serão armazenados.
