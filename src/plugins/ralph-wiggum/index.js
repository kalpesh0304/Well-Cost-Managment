import { BasePlugin } from '../base-plugin.js';

/**
 * Ralph Wiggum Plugin
 * Provides random quotes from Ralph Wiggum, the lovably clueless character from The Simpsons
 */
export class RalphWiggumPlugin extends BasePlugin {
  constructor() {
    super();
    this.name = 'RalphWiggumPlugin';
    this.version = '1.0.0';
    this.description = 'Provides random Ralph Wiggum quotes for moments of levity';

    this.quotes = [
      "Me fail English? That's unpossible!",
      "I'm learnding!",
      "Hi, Super Nintendo Chalmers!",
      "I bent my wookie.",
      "My cat's breath smells like cat food.",
      "I choo-choo-choose you!",
      "The doctor said I wouldn't have so many nose bleeds if I kept my finger outta there.",
      "I found a moonrock in my nose!",
      "I'm a unitard!",
      "That's where I saw the leprechaun. He tells me to burn things.",
      "When I grow up, I'm going to Bovine University!",
      "I heard your dad went into a restaurant and ate everything in the restaurant and they had to close the restaurant.",
      "Mrs. Krabappel and Principal Skinner were in the closet making babies and I saw one of the babies and the baby looked at me!",
      "Go banana!",
      "My parents won't let me use scissors.",
      "I dress myself!",
      "Sleep! That's where I'm a Viking!",
      "I'm Idaho!",
      "Even my boogers are spicy!",
      "Eww, Daddy, this tastes like Grandma!",
      "I ate the purple berries!",
      "They taste like burning!",
      "I'm a furniture!",
      "Principal Skinner, I got carsick in your office.",
      "What's a battle?",
      "That's my sandbox. I'm not allowed to go in the deep end."
    ];
  }

  /**
   * Initialize the plugin
   */
  async initialize() {
    console.log(`${this.name} initialized with ${this.quotes.length} quotes!`);
  }

  /**
   * Get a random Ralph Wiggum quote
   * @returns {string} A random quote
   */
  getRandomQuote() {
    const index = Math.floor(Math.random() * this.quotes.length);
    return this.quotes[index];
  }

  /**
   * Get all available quotes
   * @returns {string[]} Array of all quotes
   */
  getAllQuotes() {
    return [...this.quotes];
  }

  /**
   * Search quotes containing a specific word
   * @param {string} keyword - The keyword to search for
   * @returns {string[]} Array of matching quotes
   */
  searchQuotes(keyword) {
    const lowerKeyword = keyword.toLowerCase();
    return this.quotes.filter(quote =>
      quote.toLowerCase().includes(lowerKeyword)
    );
  }

  /**
   * Add a custom quote
   * @param {string} quote - The quote to add
   */
  addQuote(quote) {
    if (quote && typeof quote === 'string' && quote.trim()) {
      this.quotes.push(quote.trim());
    }
  }

  /**
   * Execute the plugin's main functionality
   * Returns a random quote
   * @returns {Promise<{quote: string, character: string}>}
   */
  async execute() {
    return {
      quote: this.getRandomQuote(),
      character: 'Ralph Wiggum',
      source: 'The Simpsons'
    };
  }

  /**
   * Get the quote count
   * @returns {number}
   */
  getQuoteCount() {
    return this.quotes.length;
  }
}

export default RalphWiggumPlugin;
