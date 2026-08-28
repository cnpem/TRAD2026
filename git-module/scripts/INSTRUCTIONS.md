# Instrução para execução dos scripts do projeto prático

Este arquivo contém instruções para execução dos scripts do projeto prático de controle de qualidade de dados do módulo de Git do TRAD2026.

Os exemplos abaixo utilizam o placeholder `<particao>`, que deve ser substituído pelo nome da partição do Slurm indicada para a atividade.

## Execução direta com Bash

Para executar um script diretamente no terminal, utilize:

```bash
bash run_qc.sh /caminho/para/os/dados
```

## Execução com SLURM em ambiente HPC

Para executar o script com `srun` em filas do SLURM, execute o seguinte comando no terminal:

```bash
srun --partition <particao> --cpus-per-task 4 --mem 16GB bash run_qc.sh /caminho/para/os/dados
```

Substitua `<particao>` pelo nome da partição indicada para a atividade e `/caminho/para/os/dados` pelo caminho do diretório que contém os arquivos de entrada.

> [!CAUTION]
> Não execute análises computacionalmente intensivas diretamente no nó de login do ambiente HPC. O número de CPUs, a quantidade de memória e os demais recursos solicitados podem variar de acordo com o script e a infraestrutura utilizada.
