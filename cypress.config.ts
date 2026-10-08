import { defineConfig } from "cypress";

export default defineConfig({
  e2e: {
    baseUrl: 'http://localhost:3000',
    setupNodeEvents(on, config) {
      // implement node event listeners here
      on('task', {
        accessibilityChecker: require('cypress-accessibility-checker/plugin')
      });
    },
  },
});
