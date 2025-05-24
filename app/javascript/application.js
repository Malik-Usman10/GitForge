// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "@hotwired/stimulus"
import "@hotwired/stimulus-loading"

// Import controllers
import "./controllers"

// Custom JavaScript functionality can be added here
document.addEventListener('DOMContentLoaded', function() {
  console.log('GitForge application initialized');
});
