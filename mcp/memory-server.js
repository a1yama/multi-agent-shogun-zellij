#!/usr/bin/env node
/**
 * シンプルなMemory MCPサーバー
 * 知識グラフをJSONLファイルに保存
 */

const fs = require('fs');
const path = require('path');
const readline = require('readline');

const MEMORY_FILE = path.join(__dirname, '..', 'memory', 'shogun_memory.jsonl');

// メモリデータ
let entities = [];
let relations = [];

// ファイルから読み込み
function loadMemory() {
    if (fs.existsSync(MEMORY_FILE)) {
        const lines = fs.readFileSync(MEMORY_FILE, 'utf-8').split('\n').filter(l => l.trim());
        for (const line of lines) {
            try {
                const data = JSON.parse(line);
                if (data.type === 'entity') {
                    entities.push(data);
                } else if (data.type === 'relation') {
                    relations.push(data);
                }
            } catch (e) {}
        }
    }
}

// ファイルに保存
function saveMemory() {
    const lines = [
        ...entities.map(e => JSON.stringify({ type: 'entity', ...e })),
        ...relations.map(r => JSON.stringify({ type: 'relation', ...r }))
    ];
    fs.writeFileSync(MEMORY_FILE, lines.join('\n') + '\n');
}

// MCPプロトコル処理
const tools = {
    read_graph: () => {
        return { entities, relations };
    },
    create_entities: (params) => {
        const newEntities = params.entities || [];
        for (const e of newEntities) {
            const existing = entities.find(x => x.name === e.name);
            if (existing) {
                existing.observations = [...new Set([...(existing.observations || []), ...(e.observations || [])])];
            } else {
                entities.push({ name: e.name, entityType: e.entityType, observations: e.observations || [] });
            }
        }
        saveMemory();
        return { success: true, count: newEntities.length };
    },
    add_observations: (params) => {
        const observations = params.observations || [];
        for (const obs of observations) {
            const entity = entities.find(e => e.name === obs.entityName);
            if (entity) {
                entity.observations = [...new Set([...(entity.observations || []), ...(obs.contents || [])])];
            }
        }
        saveMemory();
        return { success: true };
    },
    create_relations: (params) => {
        const newRelations = params.relations || [];
        relations.push(...newRelations);
        saveMemory();
        return { success: true };
    },
    delete_entities: (params) => {
        const names = params.entityNames || [];
        entities = entities.filter(e => !names.includes(e.name));
        saveMemory();
        return { success: true };
    }
};

// JSON-RPC処理
function handleRequest(request) {
    const { id, method, params } = request;

    if (method === 'initialize') {
        return {
            jsonrpc: '2.0',
            id,
            result: {
                protocolVersion: '2024-11-05',
                serverInfo: { name: 'memory-mcp', version: '1.0.0' },
                capabilities: { tools: {} }
            }
        };
    }

    if (method === 'tools/list') {
        return {
            jsonrpc: '2.0',
            id,
            result: {
                tools: [
                    { name: 'read_graph', description: 'メモリグラフを読み込む', inputSchema: { type: 'object', properties: {} } },
                    { name: 'create_entities', description: 'エンティティを作成', inputSchema: { type: 'object', properties: { entities: { type: 'array' } } } },
                    { name: 'add_observations', description: '観察を追加', inputSchema: { type: 'object', properties: { observations: { type: 'array' } } } },
                    { name: 'create_relations', description: '関係を作成', inputSchema: { type: 'object', properties: { relations: { type: 'array' } } } },
                    { name: 'delete_entities', description: 'エンティティを削除', inputSchema: { type: 'object', properties: { entityNames: { type: 'array' } } } }
                ]
            }
        };
    }

    if (method === 'tools/call') {
        const toolName = params.name;
        const toolParams = params.arguments || {};
        if (tools[toolName]) {
            const result = tools[toolName](toolParams);
            return {
                jsonrpc: '2.0',
                id,
                result: { content: [{ type: 'text', text: JSON.stringify(result) }] }
            };
        }
    }

    return { jsonrpc: '2.0', id, error: { code: -32601, message: 'Method not found' } };
}

// 起動
loadMemory();

const rl = readline.createInterface({ input: process.stdin, output: process.stdout, terminal: false });

rl.on('line', (line) => {
    try {
        const request = JSON.parse(line);
        const response = handleRequest(request);
        console.log(JSON.stringify(response));
    } catch (e) {
        console.log(JSON.stringify({ jsonrpc: '2.0', error: { code: -32700, message: 'Parse error' } }));
    }
});
