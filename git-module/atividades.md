# 1. Comandos git na prática

Nesta atividade, você irá explorar os principais comandos de git, aplicando-os em um repositório local. Siga as instruções abaixo para completar a atividade.

## 1.1 Configuração inicial do seu usuário

Antes de começar a usar o git, é importante configurar seu nome e email. Isso ajuda a identificar suas contribuições no repositório.

```bash
git config --global user.name "Seu Nome"
git config --global user.email "seu.email@example.com"
```

> [!TIP]
> Se você for colaborar em um projeto com outros desenvolvedores, é recomendável usar o mesmo nome e email que você utiliza no GitHub ou em outras plataformas de hospedagem de código.

## 1.2 Criando um repositório local

O próximo passo é criar um diretório para o seu projeto, use o comando abaixo para criar um novo diretório chamado `projeto` e navegar até ele:

```bash
mkdir projeto
cd projeto
```

Dentro do diretório `projeto`, inicialize um repositório git:

```bash
git init
```

Então, você verá uma mensagem indicando que o repositório foi inicializado com sucesso.

```bash
Initialized empty Git repository in /caminho/para/projeto/.git/
```

## 1.3 Criando e adicionando arquivos

Agora, crie um arquivo chamado `README.md` dentro do diretório `projeto` e adicione algum conteúdo a ele. Você pode usar o comando `echo` para isso:

```bash
echo "# Meu Projeto" > README.md
```
