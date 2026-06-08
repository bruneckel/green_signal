# Green Signal

**Projeto acadêmico — [FIAP Global Solution](https://www.fiap.com.br/graduacao/global-solution/)**

Aplicativo mobile desenvolvido no contexto do desafio **Space Connect** da graduação FIAP: usar tecnologia, dados e inovação para resolver problemas reais na Terra, conectando monitoramento ambiental e prevenção de riscos às comunidades.

Monitoramento de riscos ambientais em tempo real para a sua cidade e bairro. O app consome APIs públicas de clima e meio ambiente e não possui fins comerciais.

App Flutter com dados de qualidade do ar, temperatura, chuva, focos de incêndio e alertas meteorológicos, personalizado pela localização cadastrada do usuário.

## Global Solution — proposta

O Green Signal responde ao eixo de **previsão climática, prevenção de desastres e análise ambiental** sugerido no desafio: integra dados abertos (meteorologia, qualidade do ar, queimadas e alertas oficiais) em um protótipo mobile acessível ao cidadão, com foco em cidades e bairros.

**ODS relacionados:**

| ODS | Relação com o app |
|-----|-------------------|
| [11 — Cidades e comunidades sustentáveis](https://sdgs.un.org/goals/goal11) | Informação localizada por bairro para decisões do dia a dia |
| [13 — Ação contra a mudança global do clima](https://sdgs.un.org/goals/goal13) | Alertas, focos de incêndio e indicadores ambientais em tempo quase real |
| [9 — Indústria, inovação e infraestrutura](https://sdgs.un.org/goals/goal9) | Integração de múltiplas fontes de dados em uma solução digital |

## Funcionalidades

- **Início** — índice de risco ambiental, alertas ativos e indicadores resumidos
- **Mapa** — camadas de qualidade do ar, temperatura, chuva e focos de incêndio (INPE)
- **Alertas** — feed combinando alertas derivados dos dados ambientais e avisos do INMET
- **Bairro** — score detalhado do bairro com indicadores ambientais
- **Explorar cidades** — seletor IBGE para visualizar outras cidades sem alterar o perfil
- **Autenticação** — cadastro com endereço (CEP via ViaCEP), login e perfil editável

## Stack

- Flutter 3 / Dart 3.12+
- [go_router](https://pub.dev/packages/go_router) — navegação e shell com abas
- [flutter_map](https://pub.dev/packages/flutter_map) — mapa ambiental
- Persistência local com `shared_preferences` (usuários, cache, override de localização)

## APIs externas

| Serviço | Uso |
|---------|-----|
| [Open-Meteo](https://open-meteo.com/) | Qualidade do ar, previsão, geocodificação |
| [INPE Queimadas](https://queimadas.dgi.inpe.br/) | Focos de incêndio |
| [INMET](https://portal.inmet.gov.br/) | Alertas meteorológicos (RSS) |
| [ViaCEP](https://viacep.com.br/) | Autocompletar endereço no cadastro |
| [BrasilAPI](https://brasilapi.com.br/) | Coordenadas a partir do CEP |
| [IBGE Localidades](https://servicodados.ibge.gov.br/) | Estados e municípios no seletor de cidades |

Todas as chamadas usam HTTP público; não é necessário configurar chaves de API.

## Estrutura do projeto

```
lib/
├── core/           # Constantes, tema, utilitários
├── models/         # Modelos de domínio
├── router/         # Rotas (go_router)
├── screens/        # Telas por feature
├── services/       # Repositórios e clientes HTTP
├── shell/          # Bottom navigation
└── widgets/        # Componentes reutilizáveis
```

## Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) compatível com Dart `^3.12.1`
- Xcode (iOS) ou Android Studio / SDK (Android)

## Como rodar

```bash
flutter pub get
flutter run
```

Para um dispositivo específico:

```bash
flutter devices
flutter run -d <device_id>
```

## Testes

```bash
flutter test
```

A suíte inclui testes unitários (serviços, validadores, geocodificação) e widget tests das telas principais.

## Ícone do app

O ícone é gerado a partir de `assets/images/logo.png`:

```bash
dart run flutter_launcher_icons
```

## Localização simulada (iOS)

Para testar com coordenadas de Foz do Iguaçu no simulador iOS, use o arquivo `ios/FozDoIguacu.gpx` em **Features → Location → Custom Location** do Xcode.

## Sobre o projeto

Este repositório documenta o protótipo entregue no âmbito da **Global Solution** da FIAP. A autenticação e o cadastro de usuários são persistidos localmente no dispositivo (`shared_preferences`), sem backend próprio — adequado ao escopo acadêmico de demonstração da solução.

Mais informações sobre o evento, cronograma e orientações oficiais: [FIAP Global Solution](https://www.fiap.com.br/graduacao/global-solution/).

## Licença

Este projeto é **software livre**, distribuído sob a [Licença MIT](LICENSE).

Você pode usar, copiar, modificar e distribuir o código, desde que mantenha o aviso de copyright e a licença nos derivados.
