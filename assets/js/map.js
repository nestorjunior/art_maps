import L from 'leaflet';

// Fix para os ícones do Leaflet
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
});

export const Map = {
  mounted() {
    // Centro inicial (São Paulo)
    this.map = L.map(this.el).setView([-23.5505, -46.6333], 12);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© OpenStreetMap contributors'
    }).addTo(this.map);

    // Zoom controls (top right)
    L.control.zoom({ position: 'topright' }).addTo(this.map);

    // Location button
    const locateBtn = L.control({ position: 'topright' });
    locateBtn.onAdd = (map) => {
      const btn = L.DomUtil.create('button', 'leaflet-bar leaflet-control leaflet-control-custom');
      btn.innerHTML = '📍';
      btn.title = 'Voltar para minha localização';
      btn.style.width = '34px';
      btn.style.height = '34px';
      btn.onclick = () => {
        if (navigator.geolocation) {
          navigator.geolocation.getCurrentPosition((pos) => {
            map.setView([pos.coords.latitude, pos.coords.longitude], 15);
          });
        }
      };
      return btn;
    };
    locateBtn.addTo(this.map);

    // Adiciona pins dos murais
    const muralsData = this.el.getAttribute('data-murals');
    if (muralsData) {
      try {
        const murals = JSON.parse(muralsData);
        murals.forEach(mural => {
          if (mural.latitude && mural.longitude) {
            const marker = L.marker([mural.latitude, mural.longitude]).addTo(this.map);
            marker.bindPopup(`<strong>${mural.title}</strong><br>${mural.description || ''}`);
            marker.on('click', () => {
              // Dispara evento LiveView para abrir sidebar
              this.pushEvent("mural-selected", { id: mural.id });
            });
          }
        });
      } catch (e) {
        console.error('Erro ao parsear murais:', e);
      }
    }
  },

  updated() {
    // Optionally handle updates for new murals
  }
};
