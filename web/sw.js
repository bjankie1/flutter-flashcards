// Service Worker for Flutter Flashcards App
// This service worker handles caching and version management

const CACHE_NAME = 'flutter-flashcards-v1.0.9+2';
const STATIC_CACHE_NAME = 'flutter-flashcards-static-v1.0.9+2';

// Files to cache
const STATIC_FILES = [
  '/',
  '/index.html',
  '/manifest.json',
  '/favicon.png',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
  '/icons/Icon-maskable-192.png',
  '/icons/Icon-maskable-512.png',
];

// Install event - cache static files
self.addEventListener('install', (event) => {
  console.log('Service Worker installing...');
  event.waitUntil(
    caches.open(STATIC_CACHE_NAME)
      .then((cache) => {
        console.log('Caching static files');
        return cache.addAll(STATIC_FILES);
      })
      .then(() => {
        console.log('Service Worker installed');
        return self.skipWaiting();
      })
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
  console.log('Service Worker activating...');
  event.waitUntil(
    caches.keys()
      .then((cacheNames) => {
        return Promise.all(
          cacheNames.map((cacheName) => {
            // Delete old caches
            if (cacheName !== CACHE_NAME && cacheName !== STATIC_CACHE_NAME) {
              console.log('Deleting old cache:', cacheName);
              return caches.delete(cacheName);
            }
          })
        );
      })
      .then(() => {
        console.log('Service Worker activated');
        return self.clients.claim();
      })
  );
});

// Fetch event - handle requests
self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);
  
  // Skip non-GET requests
  if (event.request.method !== 'GET') {
    return;
  }

  // Handle Flutter assets and main.dart.js
  if (url.pathname.includes('main.dart.js') || 
      url.pathname.includes('assets/') ||
      url.pathname.includes('canvaskit/')) {
    event.respondWith(
      caches.open(CACHE_NAME)
        .then((cache) => {
          return cache.match(event.request)
            .then((response) => {
              if (response) {
                // Return cached version
                return response;
              }
              
              // Fetch from network and cache
              return fetch(event.request)
                .then((networkResponse) => {
                  if (networkResponse.status === 200) {
                    cache.put(event.request, networkResponse.clone());
                  }
                  return networkResponse;
                })
                .catch(() => {
                  // If network fails, try to return a cached version
                  return cache.match(event.request);
                });
            });
        })
    );
    return;
  }

  // Handle static files
  if (STATIC_FILES.includes(url.pathname)) {
    event.respondWith(
      caches.open(STATIC_CACHE_NAME)
        .then((cache) => {
          return cache.match(event.request)
            .then((response) => {
              if (response) {
                return response;
              }
              return fetch(event.request);
            });
        })
    );
    return;
  }

  // For other requests, try network first, then cache
  event.respondWith(
    fetch(event.request)
      .then((response) => {
        // Cache successful responses
        if (response.status === 200) {
          const responseClone = response.clone();
          caches.open(CACHE_NAME)
            .then((cache) => {
              cache.put(event.request, responseClone);
            });
        }
        return response;
      })
      .catch(() => {
        // If network fails, try cache
        return caches.match(event.request);
      })
  );
});

// Message event - handle version check requests
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'CHECK_VERSION') {
    console.log('Version check requested');
    
    // Check if there's a new version by trying to fetch the main.dart.js with a cache-busting parameter
    const versionCheckUrl = new URL(event.data.url);
    versionCheckUrl.searchParams.set('v', Date.now().toString());
    
    fetch(versionCheckUrl.toString(), { cache: 'no-cache' })
      .then((response) => {
        if (response.status === 200) {
          // Check if the response is different from cached version
          return caches.match(event.data.url)
            .then((cachedResponse) => {
              if (!cachedResponse) {
                return { hasUpdate: true };
              }
              
              // Compare response bodies (simplified check)
              return Promise.all([
                response.text(),
                cachedResponse.text()
              ]).then(([newText, cachedText]) => {
                return { hasUpdate: newText !== cachedText };
              });
            });
        }
        return { hasUpdate: false };
      })
      .catch(() => {
        return { hasUpdate: false };
      })
      .then((result) => {
        event.ports[0].postMessage(result);
      });
  }
});

// Background sync for version checking
self.addEventListener('sync', (event) => {
  if (event.tag === 'version-check') {
    console.log('Background version check triggered');
    event.waitUntil(checkForUpdates());
  }
});

// Periodic background sync (if supported)
self.addEventListener('periodicsync', (event) => {
  if (event.tag === 'version-check-periodic') {
    console.log('Periodic version check triggered');
    event.waitUntil(checkForUpdates());
  }
});

async function checkForUpdates() {
  try {
    // Check for updates by fetching the main.dart.js file
    const response = await fetch('/main.dart.js', { 
      cache: 'no-cache',
      headers: {
        'Cache-Control': 'no-cache'
      }
    });
    
    if (response.ok) {
      // Notify clients about potential update
      const clients = await self.clients.matchAll();
      clients.forEach((client) => {
        client.postMessage({
          type: 'UPDATE_AVAILABLE',
          timestamp: Date.now()
        });
      });
    }
  } catch (error) {
    console.error('Error checking for updates:', error);
  }
} 