# Plugin System Documentation

The Well Cost Management application includes a flexible plugin architecture that allows for modular functionality extensions.

## Table of Contents

- [Getting Started](#getting-started)
- [Plugin Manager](#plugin-manager)
- [Base Plugin](#base-plugin)
- [Available Plugins](#available-plugins)
  - [Ralph Wiggum Plugin](#ralph-wiggum-plugin)
- [Creating Custom Plugins](#creating-custom-plugins)

## Getting Started

### Installation

```bash
npm install
```

### Running the Application

```bash
npm start
```

### Quick Example

```javascript
import { createDefaultPluginManager } from './plugins/index.js';

const manager = createDefaultPluginManager();
await manager.initializeAll();

const ralph = manager.get('RalphWiggumPlugin');
const result = await ralph.execute();
console.log(result.quote);
```

## Plugin Manager

The `PluginManager` class handles loading, registering, and managing plugins.

### Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `register(plugin)` | `BasePlugin` | `void` | Register a plugin instance |
| `initializeAll()` | - | `Promise<void>` | Initialize all registered plugins |
| `get(name)` | `string` | `BasePlugin \| undefined` | Get a plugin by name |
| `has(name)` | `string` | `boolean` | Check if a plugin is registered |
| `getAll()` | - | `Map<string, BasePlugin>` | Get all registered plugins |
| `listPlugins()` | - | `string[]` | List all registered plugin names |
| `unregister(name)` | `string` | `Promise<void>` | Unregister a plugin |
| `destroyAll()` | - | `Promise<void>` | Destroy all plugins |

### Usage

```javascript
import { PluginManager, RalphWiggumPlugin } from './plugins/index.js';

const manager = new PluginManager();
manager.register(new RalphWiggumPlugin());
await manager.initializeAll();

// Get a specific plugin
const plugin = manager.get('RalphWiggumPlugin');

// List all plugins
console.log(manager.listPlugins());

// Cleanup
await manager.destroyAll();
```

## Base Plugin

The `BasePlugin` class is the foundation that all plugins should extend.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `name` | `string` | The plugin name |
| `version` | `string` | The plugin version |
| `description` | `string` | The plugin description |

### Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `initialize()` | - | `Promise<void>` | Initialize the plugin (override in subclass) |
| `execute()` | - | `Promise<any>` | Execute the plugin's main functionality (must be implemented) |
| `getInfo()` | - | `Object` | Get plugin information |
| `destroy()` | - | `Promise<void>` | Cleanup plugin resources (override if needed) |

### Creating a Subclass

```javascript
import { BasePlugin } from './plugins/base-plugin.js';

class MyCustomPlugin extends BasePlugin {
  constructor() {
    super();
    this.name = 'MyCustomPlugin';
    this.version = '1.0.0';
    this.description = 'My custom plugin';
  }

  async initialize() {
    // Setup code here
  }

  async execute() {
    // Main functionality here
    return { result: 'success' };
  }

  async destroy() {
    // Cleanup code here
  }
}
```

## Available Plugins

### Ralph Wiggum Plugin

Provides random quotes from Ralph Wiggum, the lovably clueless character from The Simpsons.

**Plugin Name:** `RalphWiggumPlugin`
**Version:** 1.0.0

#### Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `getRandomQuote()` | - | `string` | Get a random Ralph Wiggum quote |
| `getAllQuotes()` | - | `string[]` | Get all available quotes |
| `searchQuotes(keyword)` | `string` | `string[]` | Search quotes containing a specific word |
| `addQuote(quote)` | `string` | `void` | Add a custom quote |
| `execute()` | - | `Promise<Object>` | Returns a random quote with metadata |
| `getQuoteCount()` | - | `number` | Get the total quote count |

#### Execute Response

```javascript
{
  quote: "Me fail English? That's unpossible!",
  character: "Ralph Wiggum",
  source: "The Simpsons"
}
```

#### Usage Examples

```javascript
import { RalphWiggumPlugin } from './plugins/index.js';

const ralph = new RalphWiggumPlugin();
await ralph.initialize();

// Get a random quote
const quote = ralph.getRandomQuote();
console.log(quote);  // "I'm learnding!"

// Search for quotes
const matches = ralph.searchQuotes('cat');
console.log(matches);  // ["My cat's breath smells like cat food."]

// Execute and get full response
const result = await ralph.execute();
console.log(result);
// { quote: "Go banana!", character: "Ralph Wiggum", source: "The Simpsons" }

// Add a custom quote
ralph.addQuote("My brain hurts!");

// Get quote count
console.log(ralph.getQuoteCount());  // 27
```

#### Available Quotes

The plugin includes 26 classic Ralph Wiggum quotes:

1. "Me fail English? That's unpossible!"
2. "I'm learnding!"
3. "Hi, Super Nintendo Chalmers!"
4. "I bent my wookie."
5. "My cat's breath smells like cat food."
6. "I choo-choo-choose you!"
7. "The doctor said I wouldn't have so many nose bleeds if I kept my finger outta there."
8. "I found a moonrock in my nose!"
9. "I'm a unitard!"
10. "That's where I saw the leprechaun. He tells me to burn things."
11. "When I grow up, I'm going to Bovine University!"
12. "I heard your dad went into a restaurant and ate everything in the restaurant and they had to close the restaurant."
13. "Mrs. Krabappel and Principal Skinner were in the closet making babies and I saw one of the babies and the baby looked at me!"
14. "Go banana!"
15. "My parents won't let me use scissors."
16. "I dress myself!"
17. "Sleep! That's where I'm a Viking!"
18. "I'm Idaho!"
19. "Even my boogers are spicy!"
20. "Eww, Daddy, this tastes like Grandma!"
21. "I ate the purple berries!"
22. "They taste like burning!"
23. "I'm a furniture!"
24. "Principal Skinner, I got carsick in your office."
25. "What's a battle?"
26. "That's my sandbox. I'm not allowed to go in the deep end."

## Creating Custom Plugins

To create a custom plugin:

1. Create a new directory under `src/plugins/`
2. Extend the `BasePlugin` class
3. Implement the required `execute()` method
4. Register the plugin with the `PluginManager`

### Example: Creating a Custom Plugin

```javascript
// src/plugins/my-plugin/index.js
import { BasePlugin } from '../base-plugin.js';

export class MyPlugin extends BasePlugin {
  constructor() {
    super();
    this.name = 'MyPlugin';
    this.version = '1.0.0';
    this.description = 'Description of my plugin';
  }

  async initialize() {
    console.log('MyPlugin initialized');
  }

  async execute() {
    return { message: 'Hello from MyPlugin!' };
  }

  async destroy() {
    console.log('MyPlugin destroyed');
  }
}

export default MyPlugin;
```

### Registering the Plugin

```javascript
import { PluginManager } from './plugins/index.js';
import { MyPlugin } from './plugins/my-plugin/index.js';

const manager = new PluginManager();
manager.register(new MyPlugin());
await manager.initializeAll();
```
