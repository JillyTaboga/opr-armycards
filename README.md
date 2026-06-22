# OPR Army Cards - Visualizador e Exportador de Fichas de Exército

O **OPR Army Cards** é um aplicativo desenvolvido em Flutter projetado para converter listas de exército criadas no **One Page Rules (OPR) Army Forge** em cartões (fichas) de unidade temáticos, altamente configuráveis e prontos para uso em mesa de jogo.

O projeto oferece personalização estética completa (paletas de cores, dimensões, imagens de fundo) e ferramentas integradas para exportação digital (PNG) e física (Impressão Otimizada).

---

## 🚀 Funcionalidades Principais

*   **Integração com a API do OPR Army Forge**: Permite carregar listas de exército instantaneamente a partir do Army ID público.
*   **Temas e Paletas de Cores Personalizadas**:
    *   Temas dinâmicos baseados no sistema de jogo (Fantasy, Grimdark).
    *   Paletas estéticas premium adicionais (Noir, Obsidian, Cyber, Hive, Volcanic) configuráveis via interface.
*   **Dicionário de Regras Especiais Integrado**:
    *   Exibição automática de descrições detalhadas de regras especiais e equipamentos a partir do dicionário integrado.
    *   Fallback com as descrições oficiais extraídas diretamente do PDF de regras básicas da OPR (Ambush, AP, Blast, Caster, etc.).
*   **Customização Avançada dos Cartões**:
    *   Configuração do fundo (Sem fundo, Fundo Temático Fantasy/Grimdark ou Upload de Imagem Personalizada).
    *   Slider de controle de opacidade do fundo (0% a 100%).
    *   Sliders para ajuste fino de largura e altura das cartas (de 100px a 1000px) com redimensionamento responsivo automático.
*   **Exportação e Impressão Inteligentes**:
    *   **Exportar PNG**: Permite exportar qualquer cartão individualmente ou fazer o download em lote de todas as cartas em formato PNG de alta resolução.
    *   **Configuração de Impressão**: Painel para escolha de formato de papel (A4, Carta ou Personalizado) e toggle para orientação (Retrato ou Paisagem).
    *   **Impressão Livre de Bugs**: Cria uma aba HTML separada com as imagens estruturadas em CSS de grid de impressão e dispara o diálogo de impressão nativo do sistema operacional. Isso soluciona de forma definitiva o conhecido bug do CanvasKit (Flutter Web) que gerava impressões em tela preta.

---

## 🏗️ Arquitetura do Projeto (Clean Architecture)

O projeto foi reestruturado seguindo as diretrizes de **Arquitetura Limpa (Clean Architecture)** para garantir legibilidade, testabilidade e separação clara de responsabilidades:

```text
lib/
├── data/
│   ├── services/
│   │   ├── army_api_service.dart      # Conexão HTTP com a API Army Forge
│   │   ├── file_picker/               # Upload de arquivos (condicional Web/IO)
│   │   ├── file_saver/                # Download das imagens PNG (condicional Web/IO)
│   │   └── printer/                   # Acionador de impressão do navegador (condicional Web/IO)
├── domain/
│   ├── entities/
│   │   └── selected_file.dart         # Estrutura de dados de arquivo selecionado
│   └── services/
│       └── rule_resolver.dart         # Processamento e dicionário de Regras Especiais
├── presentation/
│   ├── pages/
│   │   └── home_page.dart             # Tela principal com controles, API e previews
│   ├── themes/
│   │   └── game_system_theme.dart     # Definição e mapeamento de cores/ícones de sistemas
│   └── widgets/
│       ├── background_config_sheet.dart  # Configuração de fundo, opacidade e tamanhos
│       ├── palette_selector.dart         # Seletor de paletas de cores
│       ├── rule_chip.dart                # Chip de exibição rápida de regra
│       ├── rule_detail_sheet.dart        # Detalhamento de regra no modal inferior
│       ├── special_item_row.dart         # Linha de item especial da unidade
│       ├── unit_card.dart                # Componente visual da carta da unidade
│       └── weapon_row.dart               # Linha de estatísticas de arma
└── main.dart                          # Inicialização do aplicativo Flutter
```

---

## 🛠️ Instalação e Execução

### Pré-requisitos
*   Flutter SDK instalado (recomendado >= 3.11.0).
*   Se estiver utilizando o FVM (Flutter Version Management), certifique-se de prefixar os comandos com `fvm`.

### Executando em Desenvolvimento

1.  Clone o repositório.
2.  Instale as dependências:
    ```bash
    flutter pub get
    ```
3.  Execute a aplicação localmente:
    ```bash
    flutter run
    ```

### Compilando para Produção (Web)

Para gerar a distribuição web otimizada pronta para hospedagem:
```bash
flutter build web --release
```
O build final estará disponível no diretório `build/web/`.
