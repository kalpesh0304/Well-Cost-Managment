/**
 * Well Cost Management Application
 * Main entry point
 */

import { createDefaultPluginManager } from './plugins/index.js';

async function main() {
  console.log('Well Cost Management System');
  console.log('===========================\n');

  // Initialize plugin manager with default plugins
  const pluginManager = createDefaultPluginManager();
  await pluginManager.initializeAll();

  console.log('\nAvailable plugins:', pluginManager.listPlugins());

  // Demo: Get a Ralph Wiggum quote
  const ralphPlugin = pluginManager.get('RalphWiggumPlugin');
  if (ralphPlugin) {
    console.log('\n--- Ralph Wiggum Quote of the Day ---');
    const result = await ralphPlugin.execute();
    console.log(`"${result.quote}"`);
    console.log(`  - ${result.character}, ${result.source}`);
  }

  // Cleanup
  await pluginManager.destroyAll();
}

main().catch(console.error);
