import L from 'leaflet';
export const Map = {
  mounted() {
    // Centro inicial (São Paulo)
    const center = { lat: -23.5505, lng: -46.6333 };
    this.map = L.map(this.el).setView([-23.5505, -46.6333], 12); // São Paulo como exemplo
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© OpenStreetMap contributors'
    }).addTo(this.map);

    // Zoom controls (top right)
    L.control.zoom({ position: 'topright' }).addTo(this.map);

    // Location button
    const locateBtn = L.control({ position: 'topright' });
    locateBtn.onAdd = function (map) {
      const btn = L.DomUtil.create('button', 'leaflet-bar leaflet-control leaflet-control-custom');
      btn.innerHTML = '📍';
      btn.title = 'Voltar para minha localização';
      btn.style.width = '34px';
      btn.style.height = '34px';
      btn.onclick = function () {
        if (navigator.geolocation) {
          navigator.geolocation.getCurrentPosition(function (pos) {
            map.setView([pos.coords.latitude, pos.coords.longitude], 15);
          });
        }
      };
      return btn;
    };
    locateBtn.addTo(this.map);

    // Street View integration (Mapillary placeholder)
    this.map.on('click', function (e) {
      // Example: open Mapillary at clicked location
      // window.open(`https://www.mapillary.com/app/?lat=${e.latlng.lat}&lng=${e.latlng.lng}&z=17`, '_blank');
    });
    // Adiciona pins dos murais
    const muralsData = this.el.getAttribute('data-murals');
    if (muralsData) {
      try {
        const murals = JSON.parse(muralsData);
        murals.forEach(mural => {
          if (mural.latitude && mural.longitude) {
            const marker = L.marker([mural.latitude, mural.longitude]).addTo(this.map);
            marker.bindPopup(`<strong>${mural.title}</strong><br>${mural.description}`);
            marker.on('click', () => {
              // Aqui pode disparar evento LiveView para abrir sidebar
              // window.dispatchEvent(new CustomEvent('mural-selected', { detail: mural }));
            });
          }
        });
      } catch (e) { }
    }
  },
  updated() {
    // Optionally handle updates for new murals
  }
};

