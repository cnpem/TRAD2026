# TRAD2026 - Aula Prática: Construindo Containers com Singularity/Apptainer

**Carga horária:** 4 h (08:00 – 12:00)
**Pré-requisitos:** acesso ao cluster via SSH, noções de Bash, aula anterior de repositórios (Git/GitHub)
**Dataset:** leituras RNA-seq pareadas de *Saccharomyces cerevisiae* em `data/raw/`

---

## Objetivos

Ao final da aula o aluno será capaz de:

1. Escrever um arquivo `.def` do zero e construir a imagem `.sif`.
2. Empacotar ferramentas de bioinformática via Conda, em **ambiente único** e em **ambientes isolados** (SCI-F apps).
3. Obter containers prontos a partir do **Seqera Containers**.
4. Diagnosticar e corrigir um `.def` defeituoso.
5. Submeter um job SLURM de controle de qualidade e versionar os resultados.

---

## Cronograma

| Horário | Bloco |
|---|---|
| 08:00 – 08:20 | Ambientação: checagem do ambiente, cache, `--fakeroot` |
| 08:20 – 09:00 | **Tarefa 1** — Container do zero |
| 09:00 – 10:00 | **Tarefa 2** — Containers com Conda (mono e multi-ambiente) |
| 10:00 – 10:15 | Intervalo |
| 10:15 – 10:35 | **Tarefa 3** — Seqera Containers |
| 10:35 – 11:05 | **Tarefa 4** — Desafio: conserte o `.def` |
| 11:05 – 11:50 | **Tarefa 5** — Job SLURM de QC + tabelas e gráficos |
| 11:50 – 12:00 | Fechamento, entrega e discussão |

---

## Bloco 0 — Instalação e ambientação (08:00)

### 0.1 Instalando o Singularity/Apptainer no Linux

> ℹ️ **Contexto**
> No cluster o runtime **já está instalado** — pule para 0.2. Esta seção serve para quem quer construir containers na própria máquina, VM ou WSL2, onde há `sudo`.

**Qual dos dois instalar?** O projeto se dividiu em 2021: **Apptainer** (Linux Foundation, sucessor comunitário, comando `apptainer` com alias `singularity`) e **SingularityCE** (Sylabs, comando `singularity`). Os `.def` deste roteiro funcionam nos dois. Instale **um** deles.

**Opção A — Apptainer via pacote (recomendado)**

```bash
# Ubuntu / Debian — PPA oficial
sudo apt update && sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:apptainer/ppa
sudo apt update && sudo apt install -y apptainer

# Rocky / AlmaLinux / RHEL 8+ — via EPEL
sudo dnf install -y epel-release
sudo dnf install -y apptainer

# Fedora
sudo dnf install -y apptainer
```

Para `.deb`/`.rpm` avulsos, baixe da página de releases (`apptainer_<versão>_amd64.deb`) e instale com `sudo dpkg -i` ou `sudo dnf install ./arquivo.rpm`.

**Opção B — SingularityCE via pacote**

```bash
# Baixe o .deb/.rpm correspondente à sua distro em
# https://github.com/sylabs/singularity/releases
wget https://github.com/sylabs/singularity/releases/download/v4.4.2/singularity-ce_4.4.2-noble_amd64.deb
sudo apt install -y ./singularity-ce_4.4.2-noble_amd64.deb
```

**Opção C — sem `sudo` (usuário comum)**

O Apptainer distribui um instalador não privilegiado, útil quando você não é admin da máquina:

```bash
curl -s https://raw.githubusercontent.com/apptainer/apptainer/main/tools/install-unprivileged.sh \
  | bash -s - ~/apptainer
export PATH=$HOME/apptainer/bin:$PATH
```

**Validação**

```bash
apptainer --version          # ou: singularity --version
apptainer exec docker://alpine:3.20 cat /etc/alpine-release
```

> ⚠️ **`apptainer` vs `singularity`**
> Ao instalar o Apptainer, o comando `singularity` normalmente existe como alias/link. Se `singularity: command not found` na sua máquina, use `apptainer` — a sintaxe é idêntica. O mesmo vale para as variáveis de ambiente: `APPTAINER_*` e `SINGULARITY_*` são intercambiáveis nas versões recentes.

> 💡 **Dica — pacote setuid**
> Existem variantes `apptainer-suid` / instalação setuid-root. Só instale se precisar de recursos que exigem privilégio (alguns cenários de mount e criptografia). Para o uso desta aula, a instalação **sem setuid** basta e é mais segura.

> 💡 **Dica — versões**
> As versões evoluem rápido (Apptainer na série 1.5.x, SingularityCE na 4.4.x em meados de 2026). Confira a versão corrente nas páginas de releases listadas nas **Referências** ao final e registre no README qual runtime e versão você usou.

### 0.2 Preparando o ambiente de trabalho

```bash
# Qual runtime está disponível?
singularity --version   # ou: apptainer --version
which singularity apptainer

# Estrutura de trabalho
cd $SCRATCH/curso-containers      # ajuste ao seu cluster
mkdir -p defs env containers data/raw results logs scripts
```

> 💡 **Dica — cache fora do `$HOME`**
> O cache de camadas passa fácil de 10 GB e estoura a cota do home. Coloque no `~/.bashrc`:
> ```bash
> export APPTAINER_CACHEDIR=$SCRATCH/.apptainer/cache
> export APPTAINER_TMPDIR=$SCRATCH/.apptainer/tmp
> # runtimes mais antigos: SINGULARITY_CACHEDIR / SINGULARITY_TMPDIR
> mkdir -p $APPTAINER_CACHEDIR $APPTAINER_TMPDIR
> ```

> ⚠️ **Atenção — build sem root**
> Em cluster você não tem `sudo`. Use `--fakeroot` (depende de *user namespaces* habilitados). Se falhar, as alternativas são:
> - `--remote` (remote builder do Apptainer/Sylabs);
> - construir em VM/notebook próprio e transferir o `.sif` por `scp`;
> - `--sandbox` em diretório, apenas para prototipar.

---

## Tarefa 1 — Um container do zero (08:20)

**Meta:** entender a anatomia de um `.def` e a diferença entre `%post` e `%environment`.

### 1.1 Escreva `defs/01_seqkit.def`

```singularity
Bootstrap: docker
From: ubuntu:22.04

%labels
    Author  seu.nome@instituicao.br
    Version 0.1.0
    Tool    seqkit 2.8.2

%help
    Container mínimo com SeqKit.
    Uso: singularity run 01_seqkit.sif stats arquivo.fasta

%post
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y --no-install-recommends wget ca-certificates procps
    rm -rf /var/lib/apt/lists/*

    mkdir -p /opt/seqkit && cd /opt/seqkit
    wget -q https://github.com/shenwei356/seqkit/releases/download/v2.8.2/seqkit_linux_amd64.tar.gz
    tar -xzf seqkit_linux_amd64.tar.gz
    rm seqkit_linux_amd64.tar.gz
    chmod +x /opt/seqkit/seqkit

%environment
    export LC_ALL=C
    export PATH="/opt/seqkit:$PATH"

%runscript
    exec seqkit "$@"

%test
    seqkit version
```

### 1.2 Construa e teste

```bash
singularity build --fakeroot containers/01_seqkit.sif defs/01_seqkit.def

singularity run   containers/01_seqkit.sif version
singularity exec  containers/01_seqkit.sif seqkit stats data/raw/*.fastq.gz
singularity shell containers/01_seqkit.sif          # explore por dentro
singularity inspect --helpfile containers/01_seqkit.sif
```

> 💡 **Dica — `%post` ≠ `%environment`**
> `export` dentro do `%post` vale **apenas durante o build**. Variáveis necessárias em tempo de execução vão no `%environment`. Este é o erro número um de quem começa.

> 💡 **Dica — prototipar rápido**
> `singularity build --sandbox --fakeroot build/ defs/01_seqkit.def` cria um diretório gravável. Entre com `singularity shell --writable build/`, teste os comandos na mão e só depois transcreva para o `%post`.

> 💡 **Dica — reprodutibilidade**
> Nunca use `From: ubuntu:latest` nem URLs `latest/download/`. Fixe a versão da base e das ferramentas — é isso que separa um container de um "funcionou na minha máquina".

---

## Tarefa 2 — Containers com Conda (09:00)

Duas estratégias para as mesmas três ferramentas: `fastqc`, `fastp` e `multiqc`.

### 2A — Ambiente único

`env/qc.yml`:

```yaml
name: qc
channels:
  - conda-forge
  - bioconda
dependencies:
  - fastqc=0.12.1
  - fastp=0.23.4
  - multiqc=1.22.3
```

`defs/02a_qc_env_unico.def`:

```singularity
Bootstrap: docker
From: condaforge/miniforge3:24.7.1-0

%files
    env/qc.yml /opt/qc.yml

%labels
    Author  seu.nome@instituicao.br
    Version 1.0.0

%post
    . /opt/conda/etc/profile.d/conda.sh
    mamba env create -f /opt/qc.yml
    conda clean -afy

%environment
    export LC_ALL=C
    export PATH="/opt/conda/envs/qc/bin:$PATH"

%runscript
    exec "$@"

%test
    fastqc --version && fastp --version && multiqc --version
```

```bash
singularity build --fakeroot containers/02a_qc.sif defs/02a_qc_env_unico.def
singularity exec containers/02a_qc.sif fastp --version
```

> 💡 **Dica — `conda activate` no `%post`**
> `conda activate` não funciona em shell não-interativo sem carregar antes o hook: `. /opt/conda/etc/profile.d/conda.sh`. Alternativa que dispensa o problema: **não ativar nada** e apontar o `PATH` direto para `/opt/conda/envs/<env>/bin` no `%environment`.

> 💡 **Dica — imagem menor e build mais rápido**
> `conda clean -afy` no fim do `%post` costuma cortar 30–50 % do tamanho final. O `mamba` já vem no miniforge e resolve o ambiente em segundos, não minutos.

### 2B — Ambientes isolados (SCI-F apps)

`defs/02b_qc_apps.def`:

```singularity
Bootstrap: docker
From: condaforge/miniforge3:24.7.1-0

%labels
    Author  seu.nome@instituicao.br
    Version 1.0.0

%post
    . /opt/conda/etc/profile.d/conda.sh
    mamba create -y -n fastqc  -c conda-forge -c bioconda fastqc=0.12.1
    mamba create -y -n fastp   -c conda-forge -c bioconda fastp=0.23.4
    mamba create -y -n multiqc -c conda-forge -c bioconda multiqc=1.22.3
    conda clean -afy

%environment
    export LC_ALL=C

%apprun fastqc
    exec /opt/conda/envs/fastqc/bin/fastqc "$@"
%apphelp fastqc
    FastQC 0.12.1 — singularity run --app fastqc <img.sif> -o out/ *.fastq.gz

%apprun fastp
    exec /opt/conda/envs/fastp/bin/fastp "$@"
%apphelp fastp
    fastp 0.23.4 — singularity run --app fastp <img.sif> -i R1 -I R2 -o ... -O ...

%apprun multiqc
    exec /opt/conda/envs/multiqc/bin/multiqc "$@"
%apphelp multiqc
    MultiQC 1.22.3 — singularity run --app multiqc <img.sif> -o out/ results/
```

```bash
singularity build --fakeroot containers/02b_qc_apps.sif defs/02b_qc_apps.def
singularity run --app fastp containers/02b_qc_apps.sif --version
singularity inspect --app multiqc --helpfile containers/02b_qc_apps.sif
```

> 💡 **Dica — quando separar os ambientes?**
> Ambiente único é mais simples e resolve a maioria dos casos. Separe quando houver **conflito de dependências** (versões incompatíveis de Python, R, Java, `libgcc`) ou quando o solver do Conda travar. Aqui o MultiQC puxa um *stack* Python pesado que costuma colidir com outras ferramentas.

> ⚠️ **Alternativa sem SCI-F**
> Dá para concatenar tudo no `PATH`:
> `export PATH="/opt/conda/envs/fastqc/bin:/opt/conda/envs/fastp/bin:/opt/conda/envs/multiqc/bin:$PATH"`
> Funciona para os binários, mas **não isola bibliotecas compartilhadas** (`LD_LIBRARY_PATH`, `PYTHONPATH`) — o conflito volta pela porta dos fundos. Vale discutir o trade-off com a turma.

---

## Tarefa 3 — Container a partir do Seqera Containers (10:05)

**Meta:** aproveitar builds prontos e reprodutíveis, sem escrever `.def`.

### Passo a passo

1. Acesse **https://seqera.io/containers/**.
2. Na aba **Conda packages**, digite `fastqc`, `fastp` e `multiqc` (pode fixar versão: `fastp=0.23.4`, `fastqc=0.12.1`, `multiqc=1.22.3`).
3. Selecione a arquitetura (**linux/amd64** para a maioria dos clusters).
4. Escolha **Singularity** como formato de saída → o site devolve uma URI `oras://`. O formato Docker devolve `docker://`.
5. Copie a URI e traga para o cluster:

```bash
# Formato Singularity nativo (recomendado)
singularity pull containers/03_qc_seqera.sif \
    oras://community.wave.seqera.io/library/fastp_fastqc_multiqc:<TAG_GERADA>

# Container pré-construído:
singularity pull containers/03_qc_seqera-pre_built.sif \
    oras://community.wave.seqera.io/library/fastp_fastqc_multiqc:42e386f910e4e983

singularity exec containers/03_qc_seqera.sif multiqc --version
```

> 💡 **Dica — a tag é o seu registro do ambiente**
> A tag é um hash determinístico do conjunto de pacotes: a mesma lista gera a mesma tag. **Anote a URI completa no README do repositório** — ela documenta o ambiente melhor que qualquer parágrafo de texto.

> ⚠️ **Atenção — retenção**
> Containers da comunidade têm retenção limitada. Para material de curso ou artigo, **guarde o `.sif`** em armazenamento próprio (ou publique num registry institucional); não dependa do link permanecer no ar.

> 💡 **Comparação para discussão (5 min)**
> Rode `du -h containers/*.sif` e compare `02a`, `02b` e `03`. Por que o do Seqera costuma ser menor? (Build multi-stage, base enxuta, sem cache do Conda dentro da imagem.)

---

## Tarefa 4 — Desafio: conserte o `.def` (10:35)

Salve o arquivo abaixo como `defs/04_desafio.def`. **Ele não constrói.** Sua missão:

1. Encontrar **todos** os defeitos (são pelo menos 6).
2. Corrigir e construir `containers/04_desafio.sif`.
3. Validar: `fastqc`, `fastp` e `multiqc` devem responder a `--version`.
4. Subir o `.def` corrigido para `defs/` no repositório, com mensagem de commit descrevendo as correções.

```singularity
Bootstrap docker
From: ubuntu:22.04

%post
    apt-get install wget
    wget -q https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
    bash Miniforge3-Linux-x86_64.sh -b -p /opt/conda
    conda activate base
    mamba install -y -c bioconda fastp multiqc
    export PATH="/opt/conda/bin:$PATH"

%runscript
    fastqc "$@"
```

### Método de trabalho sugerido

```bash
# Leia a mensagem de erro do build ANTES de mexer no arquivo
singularity build --fakeroot containers/04_desafio.sif defs/04_desafio.def 2>&1 | tee logs/build_04.log

# Reproduza o passo problemático interativamente
singularity shell docker://ubuntu:22.04
```

> 💡 **Dica — checklist de depuração**
> - A sintaxe do cabeçalho está correta (`chave: valor`)?
> - Todo `apt-get install` foi precedido de `apt-get update` e usa `-y`?
> - Download por HTTPS exige `ca-certificates` instalado.
> - O `conda` está no `PATH` no momento em que é chamado?
> - Variáveis exportadas no `%post` **não** sobrevivem ao runtime.
> - O `%runscript` chama algo que foi realmente instalado?
> - Toda ferramenta tem versão **fixada**?

<details>
<summary><b>Gabarito</b> — abrir só depois de tentar</summary>

| # | Defeito | Correção |
|---|---|---|
| 1 | `Bootstrap docker` sem dois-pontos | `Bootstrap: docker` |
| 2 | `apt-get install` sem `update` e sem `-y` (build trava esperando confirmação) | `apt-get update && apt-get install -y --no-install-recommends wget ca-certificates` |
| 3 | `wget` em HTTPS sem `ca-certificates` | incluir o pacote na mesma linha |
| 4 | `conda activate` sem carregar o hook | `. /opt/conda/etc/profile.d/conda.sh` antes |
| 5 | `mamba`/`conda` fora do `PATH` durante o `%post` | `export PATH=/opt/conda/bin:$PATH` logo após a instalação |
| 6 | `export PATH` no `%post` não persiste | mover para um bloco `%environment` |
| 7 | `%runscript` invoca `fastqc`, que nunca foi instalado | instalar `fastqc` e usar `exec` |
| 8 | `latest/download` e pacotes sem versão | fixar versões |
| 9 | Ausência de `%labels`, `%help` e `%test` | boa prática: adicionar |

Use o `defs/02a_qc_env_unico.def` como modelo da versão corrigida.
</details>

---

## Tarefa 5 — Job SLURM de controle de qualidade (11:05)

**Meta:** rodar `fastqc → fastp → fastqc → multiqc` via SLURM, extrair métricas para tabela e gráficos, e versionar.

### 5.1 `scripts/qc_slurm.sh`

```bash
#!/bin/bash
#SBATCH --job-name=qc_yeast
#SBATCH --partition=short
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=01:00:00
#SBATCH --output=logs/qc_%j.out
#SBATCH --error=logs/qc_%j.err

set -euo pipefail

SIF=$PWD/containers/02a_qc.sif
RAW=$PWD/data/raw
OUT=$PWD/results/qc
THREADS=${SLURM_CPUS_PER_TASK:-4}

mkdir -p "$OUT"/{fastqc_raw,fastp,fastqc_trim,multiqc,tables,figures} logs

# Torna o diretório de trabalho visível dentro do container
export APPTAINER_BINDPATH="$PWD"

echo "[$(date +%T)] FastQC — leituras brutas"
singularity exec "$SIF" fastqc -t "$THREADS" -o "$OUT/fastqc_raw" "$RAW"/*.fastq.gz

echo "[$(date +%T)] fastp — filtragem e remoção de adaptadores"
for R1 in "$RAW"/*_1.fastq.gz; do
    S=$(basename "$R1" _1.fastq.gz)
    R2="$RAW/${S}_2.fastq.gz"
    singularity exec "$SIF" fastp \
        -i "$R1" -I "$R2" \
        -o "$OUT/fastp/${S}_1.trim.fastq.gz" \
        -O "$OUT/fastp/${S}_2.trim.fastq.gz" \
        --detect_adapter_for_pe \
        --qualified_quality_phred 20 --length_required 36 \
        --thread "$THREADS" \
        --json "$OUT/fastp/${S}.fastp.json" \
        --html "$OUT/fastp/${S}.fastp.html"
done

echo "[$(date +%T)] FastQC — leituras filtradas"
singularity exec "$SIF" fastqc -t "$THREADS" -o "$OUT/fastqc_trim" "$OUT"/fastp/*.trim.fastq.gz

echo "[$(date +%T)] MultiQC — relatório consolidado"
singularity exec "$SIF" multiqc -f -o "$OUT/multiqc" "$OUT"

echo "[$(date +%T)] Sumarizando métricas"
singularity exec "$SIF" python3 scripts/parse_fastp.py

echo "[$(date +%T)] Concluído."
```

```bash
sbatch scripts/qc_slurm.sh
squeue -u $USER
tail -f logs/qc_<JOBID>.out
```

> 💡 **Dica — bind mounts**
> Por padrão o container só enxerga `$HOME`, `/tmp` e o diretório atual. Para dados em `/scratch` ou `/lustre`, use `-B /scratch:/scratch` ou `export APPTAINER_BINDPATH="/scratch,/lustre"`. Erro clássico do dia: *"No such file or directory"* para um arquivo que existe — é bind faltando.

> 💡 **Dica — threads**
> Sempre derive `-t/--thread` de `$SLURM_CPUS_PER_TASK`. Um `-t 16` fixo em job com `--cpus-per-task=4` gera *oversubscription* e degrada o nó inteiro.

> 💡 **Dica — usando o container de apps**
> Com o `02b_qc_apps.sif`, troque `singularity exec "$SIF" fastp ...` por `singularity run --app fastp "$SIF" ...`.

### 5.2 `scripts/parse_fastp.py` — métricas em tabela

```python
#!/usr/bin/env python3
"""Consolida os JSON do fastp em uma tabela TSV."""
import csv, glob, json, os

rows = []
for f in sorted(glob.glob("results/qc/fastp/*.fastp.json")):
    d = json.load(open(f))
    b = d["summary"]["before_filtering"]
    a = d["summary"]["after_filtering"]
    rows.append({
        "amostra":         os.path.basename(f).replace(".fastp.json", ""),
        "reads_brutas":    b["total_reads"],
        "reads_filtradas": a["total_reads"],
        "pct_retidas":     round(100 * a["total_reads"] / b["total_reads"], 2),
        "q30_antes_pct":   round(100 * b["q30_rate"], 2),
        "q30_depois_pct":  round(100 * a["q30_rate"], 2),
        "gc_pct":          round(100 * a["gc_content"], 2),
        "len_media_r1":    a["read1_mean_length"],
        "duplicacao_pct":  round(100 * d["duplication"]["rate"], 2),
    })

out = "results/qc/tables/fastp_summary.tsv"
with open(out, "w", newline="") as fh:
    w = csv.DictWriter(fh, fieldnames=rows[0].keys(), delimiter="\t")
    w.writeheader()
    w.writerows(rows)
print(f"{len(rows)} amostras escritas em {out}")
```

### 5.3 `scripts/plot_qc.R` — gráficos

```r
library(tidyverse)

d <- read_tsv("results/qc/tables/fastp_summary.tsv", show_col_types = FALSE)

# 1. Reads antes x depois da filtragem
p1 <- d |>
  select(amostra, reads_brutas, reads_filtradas) |>
  pivot_longer(-amostra, names_to = "etapa", values_to = "reads") |>
  mutate(etapa = factor(etapa,
                        levels = c("reads_brutas", "reads_filtradas"),
                        labels = c("Bruto", "Filtrado"))) |>
  ggplot(aes(fct_reorder(amostra, reads), reads / 1e6, fill = etapa)) +
  geom_col(position = position_dodge(0.8), width = 0.7) +
  coord_flip() +
  scale_fill_manual(values = c("grey65", "#2c7fb8")) +
  labs(x = NULL, y = "Milhões de reads", fill = NULL,
       title = "Reads por amostra, antes e depois do fastp") +
  theme_bw(base_size = 12)

# 2. Ganho de qualidade (Q30)
p2 <- d |>
  ggplot(aes(q30_antes_pct, q30_depois_pct, label = amostra)) +
  geom_abline(linetype = 2, colour = "grey60") +
  geom_point(size = 3, colour = "#e6550d") +
  ggrepel::geom_text_repel(size = 3) +
  labs(x = "% bases Q30 (bruto)", y = "% bases Q30 (filtrado)",
       title = "Efeito da filtragem sobre a qualidade") +
  theme_bw(base_size = 12)

dir.create("results/qc/figures", showWarnings = FALSE, recursive = TRUE)
ggsave("results/qc/figures/reads_por_amostra.png", p1, width = 7, height = 4.5, dpi = 300)
ggsave("results/qc/figures/q30_antes_depois.png",  p2, width = 6, height = 5,   dpi = 300)
```

> 💡 **Dica — R dentro do container**
> Adicione `r-base=4.4`, `r-tidyverse` e `r-ggrepel` ao `env/qc.yml` (ou crie um app `plot` no container de apps) e rode:
> `singularity exec containers/02a_qc.sif Rscript scripts/plot_qc.R`.
> Assim tabela e figura nascem do **mesmo container** que gerou os dados — reprodutibilidade de ponta a ponta.

### 5.4 Versionamento

```bash
cat >> .gitignore <<'EOF'
data/raw/
*.fastq.gz
*.sif
results/qc/fastp/*.trim.fastq.gz
EOF

git add defs/ env/ scripts/ .gitignore \
        results/qc/tables/ results/qc/figures/ \
        results/qc/multiqc/multiqc_report.html
git commit -m "QC RNA-seq S. cerevisiae: pipeline em container + tabelas e figuras"
git push
```

> ⚠️ **Nunca versione `.sif` nem FASTQ.** Um `.sif` de 1–2 GB inutiliza o repositório. Versione o **`.def`** (a receita) e, se necessário, a URI do container ou o hash de `singularity inspect`.

---

## Fechamento (11:50)

### Entregáveis no repositório

- [ ] `defs/01_seqkit.def`
- [ ] `defs/02a_qc_env_unico.def` + `env/qc.yml`
- [ ] `defs/02b_qc_apps.def`
- [ ] `README.md` com a URI do container do Seqera
- [ ] `defs/04_desafio.def` **corrigido**, com commit explicando as correções
- [ ] `scripts/qc_slurm.sh`, `scripts/parse_fastp.py`, `scripts/plot_qc.R`
- [ ] `results/qc/tables/fastp_summary.tsv`, figuras `.png` e `multiqc_report.html`

### Discussão final (5 min)

1. Quando escrever um `.def` próprio e quando puxar um container pronto?
2. `.def` versionado vs. `.sif` arquivado: que garantias cada um dá para reprodutibilidade?
3. Que parte deste pipeline você automatizaria com Nextflow/Snakemake — e o que muda no container?

### Erros mais comuns do dia (colar no quadro)

| Sintoma | Causa provável |
|---|---|
| `command not found` ao rodar o container | `PATH` exportado no `%post` em vez do `%environment` |
| Build trava sem sair | `apt-get install` sem `-y` |
| `conda: command not found` | falta `. /opt/conda/etc/profile.d/conda.sh` |
| `No such file or directory` com arquivo que existe | bind mount ausente |
| Disco cheio / cota estourada | `APPTAINER_CACHEDIR` apontando para o `$HOME` |
| Resultado diferente do da semana passada | versões não fixadas |

---

## Referências e links úteis

### Documentação oficial dos runtimes

| Recurso | Link |
|---|---|
| Apptainer — User Guide (última versão) | https://apptainer.org/docs/user/latest/ |
| Apptainer — Definition Files (referência das seções) | https://apptainer.org/docs/user/latest/definition_files.html |
| Apptainer — Admin Guide / instalação | https://apptainer.org/docs/admin/latest/installation.html |
| Apptainer — releases | https://github.com/apptainer/apptainer/releases |
| SingularityCE — User Guide | https://docs.sylabs.io/guides/latest/user-guide/ |
| SingularityCE — Admin Guide / instalação | https://docs.sylabs.io/guides/latest/admin-guide/installation.html |
| SingularityCE — releases | https://github.com/sylabs/singularity/releases |

### Tópicos específicos

| Tema | Link |
|---|---|
| Bind mounts e sistemas de arquivos | https://apptainer.org/docs/user/latest/bind_paths_and_mounts.html |
| Variáveis de ambiente e `%environment` | https://apptainer.org/docs/user/latest/environment_and_metadata.html |
| Build `--fakeroot` sem root | https://apptainer.org/docs/user/latest/fakeroot.html |
| Apps SCI-F (`%apprun`, `%apphelp`) | https://apptainer.org/docs/user/latest/definition_files.html#apps |
| Suporte a GPU (`--nv`, `--rocm`) | https://apptainer.org/docs/user/latest/gpu.html |
| Especificação SCI-F | https://sci-f.github.io/ |

### Registries e containers prontos

| Recurso | Link |
|---|---|
| Seqera Containers (gerador usado na Tarefa 3) | https://seqera.io/containers/ |
| Wave — documentação | https://docs.seqera.io/wave |
| BioContainers — registry | https://biocontainers.pro/registry |
| Galaxy Depot (imagens do Bioconda) | https://depot.galaxyproject.org/singularity/ |
| Docker Hub | https://hub.docker.com/ |
| Quay.io (host dos BioContainers) | https://quay.io/organization/biocontainers |

### Conda / Bioconda

| Recurso | Link |
|---|---|
| Bioconda — pacotes disponíveis | https://bioconda.github.io/conda-package_index.html |
| Miniforge (base usada nos `.def`) | https://github.com/conda-forge/miniforge |
| Boas práticas de ambientes Conda | https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html |

### Ferramentas da Tarefa 5

| Ferramenta | Link |
|---|---|
| FastQC | https://www.bioinformatics.babraham.ac.uk/projects/fastqc/ |
| fastp — repositório e manual | https://github.com/OpenGene/fastp |
| MultiQC — documentação | https://docs.seqera.io/multiqc |
| SLURM — `sbatch` | https://slurm.schedmd.com/sbatch.html |

### Leitura complementar

| Tema | Link |
|---|---|
| Kurtzer et al. (2017), artigo original do Singularity | https://doi.org/10.1371/journal.pone.0177459 |
| Gruening et al. (2018), reprodutibilidade em bioinformática | https://doi.org/10.1016/j.cels.2018.03.014 |
| Nextflow — uso de containers | https://www.nextflow.io/docs/latest/container.html |
| Snakemake — integração com Apptainer/Conda | https://snakemake.readthedocs.io/en/stable/snakefiles/deployment.html |

> 💡 **Dica final**
> A documentação do Apptainer usa o caminho `/latest/` nas URLs — sempre aponta para a versão corrente. Ao citar comportamento específico em relatórios ou material didático, troque `latest` pela versão exata (ex.: `/1.5/`) para que o link continue descrevendo o que você testou.
