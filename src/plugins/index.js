/**
 * Plugin Manager
 * Handles loading, registering, and managing plugins
 */

import { RalphWiggumPlugin } from './ralph-wiggum/index.js';

export class PluginManager {
  constructor() {
    this.plugins = new Map();
  }

  /**
   * Register a plugin
   * @param {BasePlugin} plugin - The plugin instance to register
   */
  register(plugin) {
    if (this.plugins.has(plugin.name)) {
      console.warn(`Plugin ${plugin.name} is already registered. Skipping.`);
      return;
    }
    this.plugins.set(plugin.name, plugin);
    console.log(`Registered plugin: ${plugin.name}`);
  }

  /**
   * Initialize all registered plugins
   */
  async initializeAll() {
    for (const [name, plugin] of this.plugins) {
      try {
        await plugin.initialize();
        console.log(`Initialized plugin: ${name}`);
      } catch (error) {
        console.error(`Failed to initialize plugin ${name}:`, error);
      }
    }
  }

  /**
   * Get a plugin by name
   * @param {string} name - The plugin name
   * @returns {BasePlugin|undefined}
   */
  get(name) {
    return this.plugins.get(name);
  }

  /**
   * Check if a plugin is registered
   * @param {string} name - The plugin name
   * @returns {boolean}
   */
  has(name) {
    return this.plugins.has(name);
  }

  /**
   * Get all registered plugins
   * @returns {Map<string, BasePlugin>}
   */
  getAll() {
    return new Map(this.plugins);
  }

  /**
   * List all registered plugin names
   * @returns {string[]}
   */
  listPlugins() {
    return Array.from(this.plugins.keys());
  }

  /**
   * Unregister a plugin
   * @param {string} name - The plugin name
   */
  async unregister(name) {
    const plugin = this.plugins.get(name);
    if (plugin) {
      await plugin.destroy();
      this.plugins.delete(name);
      console.log(`Unregistered plugin: ${name}`);
    }
  }

  /**
   * Destroy all plugins
   */
  async destroyAll() {
    for (const [name, plugin] of this.plugins) {
      try {
        await plugin.destroy();
        console.log(`Destroyed plugin: ${name}`);
      } catch (error) {
        console.error(`Failed to destroy plugin ${name}:`, error);
      }
    }
    this.plugins.clear();
  }
}

// Export available plugins
export { RalphWiggumPlugin };
export { BasePlugin } from './base-plugin.js';

// Create a default plugin manager instance with built-in plugins
export function createDefaultPluginManager() {
  const manager = new PluginManager();
  manager.register(new RalphWiggumPlugin());
  return manager;
}
