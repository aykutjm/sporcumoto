/**
 * Supabase Helper Library
 * Firebase API'sini taklit eden wrapper fonksiyonlar
 * Bu sayede mevcut kodu minimum değişiklikle Supabase'e geçirebiliriz
 */

// Supabase client will be initialized in each HTML file
let supabaseClient = null;
let currentUser = null;
let currentClubId = null;

// Initialize Supabase client
function initSupabase(url, anonKey) {
    supabaseClient = window.supabase.createClient(url, anonKey);
    return supabaseClient;
}

// Auth wrapper functions
const auth = {
    async signInWithEmailAndPassword(email, password) {
        const { data, error } = await supabaseClient.auth.signInWithPassword({
            email,
            password
        });
        if (error) throw error;
        currentUser = data.user;
        return { user: data.user };
    },
    
    async signOut() {
        const { error } = await supabaseClient.auth.signOut();
        if (error) throw error;
        currentUser = null;
    },
    
    async onAuthStateChanged(callback) {
        const { data: { session } } = await supabaseClient.auth.getSession();
        if (session) {
            currentUser = session.user;
            callback(session.user);
        }
        
        const { data: authListener } = supabaseClient.auth.onAuthStateChange(
            (event, session) => {
                currentUser = session?.user || null;
                callback(session?.user || null);
            }
        );
        
        return authListener;
    },
    
    async getCurrentUser() {
        const { data: { user } } = await supabaseClient.auth.getUser();
        currentUser = user;
        return user;
    }
};

// Firestore-like wrapper functions
const db = {
    // Collection reference
    collection(tableName) {
        return {
            tableName,
            query: supabaseClient.from(tableName)
        };
    },
    
    // Get all documents from a collection
    async getDocs(collectionRef, queryOptions = {}) {
        let query = supabaseClient.from(collectionRef.tableName).select('*');
        
        // Apply filters if any
        if (queryOptions.where) {
            for (const condition of queryOptions.where) {
                const [field, operator, value] = condition;
                switch (operator) {
                    case '==':
                        query = query.eq(field, value);
                        break;
                    case '!=':
                        query = query.neq(field, value);
                        break;
                    case '>':
                        query = query.gt(field, value);
                        break;
                    case '>=':
                        query = query.gte(field, value);
                        break;
                    case '<':
                        query = query.lt(field, value);
                        break;
                    case '<=':
                        query = query.lte(field, value);
                        break;
                    case 'in':
                        query = query.in(field, value);
                        break;
                    case 'array-contains':
                        query = query.contains(field, [value]);
                        break;
                }
            }
        }
        
        // Apply ordering
        if (queryOptions.orderBy) {
            const [field, direction = 'asc'] = queryOptions.orderBy;
            query = query.order(field, { ascending: direction === 'asc' });
        }
        
        // Apply limit
        if (queryOptions.limit) {
            query = query.limit(queryOptions.limit);
        }
        
        const { data, error } = await query;
        
        if (error) throw error;
        
        // Return in Firestore format
        const docs = data.map(doc => ({
            id: doc.id,
            data: () => doc,
            exists: () => true
        }));
        
        return {
            docs: docs,
            size: data.length,
            empty: data.length === 0,
            // Firebase uyumlu: docChanges() metodu
            docChanges: () => docs.map(doc => ({
                type: 'added', // İlk yüklemede hepsi 'added'
                doc: doc
            }))
        };
    },
    
    // Get a single document
    async getDoc(docRef) {
        const { data, error } = await supabaseClient
            .from(docRef.tableName)
            .select('*')
            .eq('id', docRef.id)
            .single();
        
        if (error && error.code !== 'PGRST116') throw error; // PGRST116 = not found
        
        return {
            id: docRef.id,
            data: () => data || {},
            exists: () => !!data
        };
    },
    
    // Add a document
    async addDoc(collectionRef, data) {
        // Add clubId if available and not present
        if (currentClubId && !data.clubId) {
            data.clubId = currentClubId;
        }
        
        // Generate ID if not present (PostgreSQL TEXT PRIMARY KEY)
        if (!data.id) {
            data.id = `${collectionRef.tableName}_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
        }
        
        // Firebase uyumlu şema - field dönüşümü YAPMA!
        // const convertedData = convertToSnakeCase(data);
        
        const { data: result, error } = await supabaseClient
            .from(collectionRef.tableName)
            .insert([data])
            .select()
            .single();
        
        if (error) throw error;
        
        return {
            id: result.id,
            data: () => result
        };
    },
    
    // Update a document
    async updateDoc(docRef, data) {
        // Firebase uyumlu şema - field dönüşümü YAPMA!
        // const convertedData = convertToSnakeCase(data);
        
        const { data: result, error } = await supabaseClient
            .from(docRef.tableName)
            .update(data)
            .eq('id', docRef.id)
            .select()
            .single();
        
        if (error) throw error;
        
        return result;
    },
    
    // Delete a document
    async deleteDoc(docRef) {
        const { error } = await supabaseClient
            .from(docRef.tableName)
            .delete()
            .eq('id', docRef.id);
        
        if (error) throw error;
    },
    
    // Set a document (create or replace)
    async setDoc(docRef, data) {
        // Firebase uyumlu şema - field dönüşümü YAPMA!
        // const convertedData = convertToSnakeCase(data);
        data.id = docRef.id;
        
        const { data: result, error } = await supabaseClient
            .from(docRef.tableName)
            .upsert([data])
            .select()
            .single();
        
        if (error) throw error;
        
        return result;
    },
    
    // Document reference
    doc(tableName, id) {
        return {
            tableName,
            id
        };
    },
    
    // Query builder
    query(collectionRef, ...conditions) {
        const queryOptions = { where: [], orderBy: null, limit: null };
        
        conditions.forEach(condition => {
            if (condition.type === 'where') {
                queryOptions.where.push([condition.field, condition.operator, condition.value]);
            } else if (condition.type === 'orderBy') {
                queryOptions.orderBy = [condition.field, condition.direction];
            } else if (condition.type === 'limit') {
                queryOptions.limit = condition.value;
            }
        });
        
        return {
            ...collectionRef,
            queryOptions
        };
    },
    
    // Real-time subscription (using Supabase realtime)
    onSnapshot(collectionRef, callback, errorCallback) {
        const tableName = collectionRef.tableName;
        let previousDocs = [];
        
        // Helper: Snapshot'ı oluştur
        const createSnapshot = (docs) => {
            // Önceki snapshot ile karşılaştır
            const changes = [];
            const previousIds = new Set(previousDocs.map(d => d.id));
            const currentIds = new Set(docs.map(d => d.id));
            
            // Added & Modified
            docs.forEach(doc => {
                if (!previousIds.has(doc.id)) {
                    changes.push({ type: 'added', doc: doc });
                } else {
                    // Check if modified (basit kontrol: JSON karşılaştır)
                    const prev = previousDocs.find(d => d.id === doc.id);
                    if (prev && JSON.stringify(prev.data()) !== JSON.stringify(doc.data())) {
                        changes.push({ type: 'modified', doc: doc });
                    }
                }
            });
            
            // Removed
            previousDocs.forEach(doc => {
                if (!currentIds.has(doc.id)) {
                    changes.push({ type: 'removed', doc: doc });
                }
            });
            
            previousDocs = docs; // Güncelle
            
            return {
                docs: docs,
                size: docs.length,
                empty: docs.length === 0,
                docChanges: () => changes
            };
        };
        
        // Initial fetch
        this.getDocs(collectionRef, collectionRef.queryOptions || {})
            .then(result => {
                const snapshot = createSnapshot(result.docs);
                callback(snapshot);
            })
            .catch(err => errorCallback && errorCallback(err));
        
        // Setup realtime subscription
        const subscription = supabaseClient
            .channel(`public:${tableName}`)
            .on('postgres_changes', 
                { event: '*', schema: 'public', table: tableName },
                (payload) => {
                    // Refetch on any change
                    this.getDocs(collectionRef, collectionRef.queryOptions || {})
                        .then(result => {
                            const snapshot = createSnapshot(result.docs);
                            callback(snapshot);
                        })
                        .catch(err => errorCallback && errorCallback(err));
                }
            )
            .subscribe();
        
        // Return unsubscribe function
        return () => {
            subscription.unsubscribe();
        };
    }
};

// Query condition builders (Firebase-like)
function where(field, operator, value) {
    return { type: 'where', field, operator, value };
}

function orderBy(field, direction = 'asc') {
    return { type: 'orderBy', field, direction };
}

function limit(value) {
    return { type: 'limit', value };
}

// Array operations (Firebase-like)
const arrayUnion = (...elements) => ({
    _type: 'arrayUnion',
    elements
});

const arrayRemove = (...elements) => ({
    _type: 'arrayRemove',
    elements
});

// Convert camelCase to snake_case
function convertToSnakeCase(obj) {
    if (!obj || typeof obj !== 'object') return obj;
    
    if (Array.isArray(obj)) {
        return obj.map(item => convertToSnakeCase(item));
    }
    
    const converted = {};
    for (const [key, value] of Object.entries(obj)) {
        // Skip special Firebase operations
        if (value && value._type) {
            converted[toSnakeCase(key)] = value;
            continue;
        }
        
        const snakeKey = toSnakeCase(key);
        
        if (value && typeof value === 'object' && !Array.isArray(value) && !(value instanceof Date)) {
            converted[snakeKey] = convertToSnakeCase(value);
        } else {
            converted[snakeKey] = value;
        }
    }
    return converted;
}

function toSnakeCase(str) {
    // Common mappings
    const mappings = {
        'clubName': 'club_name',
        'clubId': 'club_id',
        'adminEmail': 'admin_email',
        'adminPhone': 'admin_phone',
        'adminName': 'admin_name',
        'memberCount': 'member_count',
        'createdAt': 'created_at',
        'updatedAt': 'updated_at',
        'fullName': 'full_name',
        'birthDate': 'birth_date',
        'parent1Name': 'parent1_name',
        'parent1Phone': 'parent1_phone',
        'parent2Name': 'parent2_name',
        'parent2Phone': 'parent2_phone',
        'isActive': 'is_active',
        'memberId': 'member_id',
        'groupId': 'group_id',
        'phoneNumber': 'phone_number',
        'messageText': 'message_text',
        'sentAt': 'sent_at',
        'createdBy': 'created_by'
        // Add more as needed
    };
    
    if (mappings[str]) return mappings[str];
    
    // Generic conversion
    return str.replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`);
}

// Convert snake_case to camelCase (for reading data)
function convertToCamelCase(obj) {
    if (!obj || typeof obj !== 'object') return obj;
    
    if (Array.isArray(obj)) {
        return obj.map(item => convertToCamelCase(item));
    }
    
    const converted = {};
    for (const [key, value] of Object.entries(obj)) {
        const camelKey = toCamelCase(key);
        
        if (value && typeof value === 'object' && !Array.isArray(value) && !(value instanceof Date)) {
            converted[camelKey] = convertToCamelCase(value);
        } else {
            converted[camelKey] = value;
        }
    }
    return converted;
}

function toCamelCase(str) {
    return str.replace(/_([a-z])/g, (match, letter) => letter.toUpperCase());
}

// Set current club ID (for multi-tenant support)
function setCurrentClubId(clubId) {
    currentClubId = clubId;
}

// Export for use in HTML files
window.supabaseHelper = {
    initSupabase,
    auth,
    db,
    where,
    orderBy,
    limit,
    arrayUnion,
    arrayRemove,
    setCurrentClubId,
    convertToCamelCase,
    convertToSnakeCase
};

