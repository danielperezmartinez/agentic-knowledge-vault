// @ts-check
// Configuración de Docusaurus para el sitio de agentic-knowledge-vault.
// Inglés servido en la raíz; español en /es/.

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'agentic-knowledge-vault',
  tagline: 'A shared knowledge vault for humans and AI agents',

  url: 'https://danielperezmartinez.github.io',
  baseUrl: '/agentic-knowledge-vault/',
  organizationName: 'danielperezmartinez',
  projectName: 'agentic-knowledge-vault',

  onBrokenLinks: 'warn',
  markdown: {
    hooks: {
      onBrokenMarkdownLinks: 'warn',
    },
  },

  i18n: {
    defaultLocale: 'en',
    locales: ['en', 'es'],
    localeConfigs: {
      en: { label: 'English' },
      es: { label: 'Español' },
    },
  },

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: false,
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      navbar: {
        title: 'agentic-knowledge-vault',
        items: [
          {
            href: 'https://github.com/danielperezmartinez/agentic-knowledge-vault',
            label: 'GitHub',
            position: 'right',
          },
          {
            type: 'localeDropdown',
            position: 'right',
          },
        ],
      },
      footer: {
        style: 'dark',
        copyright: `© ${new Date().getFullYear()} Daniel Pérez Martínez · MIT`,
      },
    }),
};

module.exports = config;
