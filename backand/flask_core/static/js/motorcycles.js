// Глобальные переменные
let currentFilters = {
    group: '',
    series: '',
    category: '',
    search: '',
    sort: 'name-asc',
    page: 1,
    per_page: 12
};

let allGroups = [];
let allSeries = [];
let allCategories = [];

// Инициализация
document.addEventListener('DOMContentLoaded', () => {
    loadHierarchyData();
    loadMotorcycles();
    setupEventListeners();
});

// Загружаем уникальные значения для иерархии
async function loadHierarchyData() {
    try {
        const response = await fetch('/api/motorcycles');
        const data = await response.json();
        
        if (response.ok) {
            // Извлекаем уникальные группы
            allGroups = [...new Set(data.motorcycles.map(m => m.group))];
            
            // Извлекаем уникальные серии
            allSeries = [...new Set(data.motorcycles.map(m => m.series))];
            
            // Извлекаем уникальные категории
            allCategories = [...new Set(data.motorcycles.map(m => m.category))];
        }
    } catch (error) {
        console.error('Error loading hierarchy:', error);
    }
}

// Загрузка мотоциклов с фильтрами
async function loadMotorcycles() {
    const grid = document.getElementById('motorcyclesGrid');
    const emptyState = document.getElementById('emptyState');
    const resultsCount = document.getElementById('resultsCount');
    const paginationInfo = document.getElementById('paginationInfo');
    
    grid.innerHTML = '<div class="loading-spinner"><div class="spinner"></div><p>Loading...</p></div>';
    
    try {
        // Формируем параметры запроса
        const params = new URLSearchParams();
        if (currentFilters.group) params.append('group', currentFilters.group);
        if (currentFilters.series) params.append('series', currentFilters.series);
        if (currentFilters.category) params.append('category', currentFilters.category);
        if (currentFilters.search) params.append('search', currentFilters.search);
        
        const [sortBy, sortOrder] = currentFilters.sort.split('-');
        params.append('sort', sortBy);
        params.append('order', sortOrder);
        params.append('page', currentFilters.page);
        params.append('per_page', currentFilters.per_page);
        
        const response = await fetch(`/api/motorcycles/list?${params}`);
        const data = await response.json();
        
        if (response.ok) {
            resultsCount.textContent = data.total;
            paginationInfo.textContent = `Page ${data.page} of ${data.pages}`;
            
            if (data.motorcycles.length === 0) {
                grid.style.display = 'none';
                emptyState.style.display = 'block';
            } else {
                grid.style.display = 'grid';
                emptyState.style.display = 'none';
                renderMotorcycles(data.motorcycles);
                renderPagination(data.page, data.pages);
            }
        } else {
            grid.innerHTML = `<p class="error">Error: ${data.error}</p>`;
        }
    } catch (error) {
        console.error('Fetch error:', error);
        grid.innerHTML = '<p class="error">Failed to load motorcycles</p>';
    }
}

// Рендер карточек
function renderMotorcycles(motorcycles) {
    const grid = document.getElementById('motorcyclesGrid');
    grid.innerHTML = '';
    
    motorcycles.forEach(moto => {
        const card = document.createElement('div');
        card.className = 'moto-card';
        card.onclick = () => showMotorcycleDetails(moto);
        
        const imagePath = moto.image && !moto.image.startsWith('http') 
            ? `/static/img/motorcycles/${moto.image}` 
            : moto.image || '/static/img/motorcycles/placeholder.jpg';
        
        card.innerHTML = `
            <div class="moto-image">
                <img src="${imagePath}" alt="${moto.name}" onerror="this.src='/static/img/motorcycles/placeholder.jpg'">
            </div>
            <div class="moto-info">
                <h3>${moto.name}</h3>
                <p class="moto-series">${moto.series.name}</p>
                <p class="moto-price">$${moto.price ? moto.price.toLocaleString() : 'N/A'}</p>
                <p class="moto-year">${moto.year}</p>
            </div>
        `;
        grid.appendChild(card);
    });
}

// Рендер пагинации
function renderPagination(currentPage, totalPages) {
    const pagination = document.getElementById('pagination');
    pagination.innerHTML = '';
    
    // Кнопка "Назад"
    const prevBtn = document.createElement('button');
    prevBtn.textContent = '←';
    prevBtn.disabled = currentPage === 1;
    prevBtn.onclick = () => {
        if (currentPage > 1) {
            currentFilters.page = currentPage - 1;
            loadMotorcycles();
        }
    };
    pagination.appendChild(prevBtn);
    
    // Номера страниц (показываем максимум 5)
    const startPage = Math.max(1, currentPage - 2);
    const endPage = Math.min(totalPages, startPage + 4);
    
    for (let i = startPage; i <= endPage; i++) {
        const btn = document.createElement('button');
        btn.textContent = i;
        btn.className = i === currentPage ? 'active' : '';
        btn.onclick = () => {
            currentFilters.page = i;
            loadMotorcycles();
        };
        pagination.appendChild(btn);
    }
    
    // Кнопка "Вперёд"
    const nextBtn = document.createElement('button');
    nextBtn.textContent = '→';
    nextBtn.disabled = currentPage === totalPages;
    nextBtn.onclick = () => {
        if (currentPage < totalPages) {
            currentFilters.page = currentPage + 1;
            loadMotorcycles();
        }
    };
    pagination.appendChild(nextBtn);
}

// Обработчики событий для иерархической навигации
function setupEventListeners() {
    // Level 1: Groups
    document.querySelectorAll('#groupsList .hierarchy-btn').forEach(btn => {
        btn.onclick = (e) => {
            // Обновляем активную кнопку
            document.querySelectorAll('#groupsList .hierarchy-btn').forEach(b => b.classList.remove('active'));
            e.currentTarget.classList.add('active');
            
            // Сбрасываем зависимые уровни
            currentFilters.group = e.currentTarget.dataset.value;
            currentFilters.series = '';
            currentFilters.category = '';
            currentFilters.page = 1;
            
            // Показываем/скрываем следующие уровни
            updateHierarchyLevels();
            loadMotorcycles();
        };
    });
    
    // Search
    document.getElementById('searchBtn').onclick = () => {
        currentFilters.search = document.getElementById('searchInput').value;
        currentFilters.page = 1;
        loadMotorcycles();
    };
    
    document.getElementById('searchInput').onkeypress = (e) => {
        if (e.key === 'Enter') {
            currentFilters.search = e.target.value;
            currentFilters.page = 1;
            loadMotorcycles();
        }
    };
    
    // Sort
    document.getElementById('sortSelect').onchange = (e) => {
        currentFilters.sort = e.target.value;
        currentFilters.page = 1;
        loadMotorcycles();
    };
    
    // Modal close
    document.querySelector('.close-modal').onclick = () => {
        document.getElementById('motorcycleModal').style.display = 'none';
    };
    
    window.onclick = (e) => {
        if (e.target.id === 'motorcycleModal') {
            document.getElementById('motorcycleModal').style.display = 'none';
        }
    };
}

// Обновление видимости уровней иерархии
function updateHierarchyLevels() {
    const levelSeries = document.getElementById('level-series');
    const levelCategories = document.getElementById('level-categories');
    const seriesList = document.getElementById('seriesList');
    const categoriesList = document.getElementById('categoriesList');
    
    // Level 2: Series (показываем если выбрана группа)
    if (currentFilters.group && currentFilters.group !== 'all') {
        levelSeries.classList.remove('hidden');
        
        // Фильтруем серии по выбранной группе
        const filteredSeries = allSeries.filter(s => 
            s.group.slug === currentFilters.group || currentFilters.group === 'all'
        );
        
        seriesList.innerHTML = `
            <button class="hierarchy-btn ${!currentFilters.series ? 'active' : ''}" data-value="">All Series</button>
            ${filteredSeries.map(s => `
                <button class="hierarchy-btn ${currentFilters.series === s.name ? 'active' : ''}" 
                        data-value="${s.name}">${s.name}</button>
            `).join('')}
        `;
        
        // Добавляем обработчики для новых кнопок
        seriesList.querySelectorAll('.hierarchy-btn').forEach(btn => {
            btn.onclick = (e) => {
                document.querySelectorAll('#seriesList .hierarchy-btn').forEach(b => b.classList.remove('active'));
                e.currentTarget.classList.add('active');
                
                currentFilters.series = e.currentTarget.dataset.value;
                currentFilters.category = '';
                currentFilters.page = 1;
                
                updateHierarchyLevels();
                loadMotorcycles();
            };
        });
    } else {
        levelSeries.classList.add('hidden');
        levelCategories.classList.add('hidden');
    }
    
    // Level 3: Categories (показываем если выбрана серия)
    if (currentFilters.series) {
        levelCategories.classList.remove('hidden');
        
        // Фильтруем категории по выбранной серии
        const filteredCategories = allCategories.filter(c => 
            // Здесь можно добавить логику фильтрации по серии, если нужно
            true
        );
        
        categoriesList.innerHTML = `
            <button class="hierarchy-btn ${!currentFilters.category ? 'active' : ''}" data-value="">All Categories</button>
            ${filteredCategories.map(c => `
                <button class="hierarchy-btn ${currentFilters.category === c.name ? 'active' : ''}" 
                        data-value="${c.name}">${c.name}</button>
            `).join('')}
        `;
        
        categoriesList.querySelectorAll('.hierarchy-btn').forEach(btn => {
            btn.onclick = (e) => {
                document.querySelectorAll('#categoriesList .hierarchy-btn').forEach(b => b.classList.remove('active'));
                e.currentTarget.classList.add('active');
                
                currentFilters.category = e.currentTarget.dataset.value;
                currentFilters.page = 1;
                
                loadMotorcycles();
            };
        });
    } else {
        levelCategories.classList.add('hidden');
    }
}

// Показать детали мотоцикла
function showMotorcycleDetails(moto) {
    const modal = document.getElementById('motorcycleModal');
    const content = document.getElementById('modalContent');
    const specs = moto.specs;
    
    content.innerHTML = `
        <h2>${moto.name} (${moto.year})</h2>
        <p class="modal-series">${moto.series.name} • ${moto.category.name}</p>
        <p class="modal-price">$${moto.price ? moto.price.toLocaleString() : 'N/A'}</p>
        
        <div class="specs-grid">
            ${specs.engine_type ? `<div><strong>Engine:</strong> ${specs.engine_type}</div>` : ''}
            ${specs.displacement_cc ? `<div><strong>Displacement:</strong> ${specs.displacement_cc} cc</div>` : ''}
            ${specs.horsepower ? `<div><strong>Power:</strong> ${specs.horsepower}</div>` : ''}
            ${specs.torque ? `<div><strong>Torque:</strong> ${specs.torque}</div>` : ''}
            ${specs.transmission ? `<div><strong>Transmission:</strong> ${specs.transmission}</div>` : ''}
            ${specs.seat_height ? `<div><strong>Seat Height:</strong> ${specs.seat_height}"</div>` : ''}
            ${specs.fuel_capacity ? `<div><strong>Fuel Capacity:</strong> ${specs.fuel_capacity} gal</div>` : ''}
            ${specs.weight ? `<div><strong>Weight:</strong> ${specs.weight} lbs</div>` : ''}
        </div>
    `;
    
    modal.style.display = 'flex';
}

// Сброс всех фильтров
function resetAll() {
    currentFilters = {
        group: '',
        series: '',
        category: '',
        search: '',
        sort: 'name-asc',
        page: 1,
        per_page: 12
    };
    
    // Сброс UI
    document.querySelectorAll('.hierarchy-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelector('#groupsList [data-value="all"]').classList.add('active');
    document.getElementById('searchInput').value = '';
    document.getElementById('sortSelect').value = 'name-asc';
    
    updateHierarchyLevels();
    loadMotorcycles();
}