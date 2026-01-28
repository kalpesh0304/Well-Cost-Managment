/**
 * Base Plugin class that all plugins should extend
 */
export class BasePlugin {
  constructor() {
    this.name = 'BasePlugin';
    this.version = '1.0.0';
    this.description = 'Base plugin class';
  }

  /**
   * Initialize the plugin
   * @returns {Promise<void>}
   */
  async initialize() {
    // Override in subclass
  }

  /**
   * Execute the plugin's main functionality
   * @returns {Promise<any>}
   */
  async execute() {
    throw new Error('execute() must be implemented by subclass');
  }

  /**
   * Get plugin information
   * @returns {Object}
   */
  getInfo() {
    return {
      name: this.name,
      version: this.version,
      description: this.description
    };
  }

  /**
   * Cleanup plugin resources
   * @returns {Promise<void>}
   */
  async destroy() {
    // Override in subclass if needed
  }
}
