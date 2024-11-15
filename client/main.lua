--		  █████╗ ██████╗ ██████╗ ███████╗██╗     ██████╗ ███╗   ███╗██████╗
--		 ██╔══██╗██╔══██╗██╔══██╗██╔════╝██║     ██╔══██╗████╗ ████║██╔══██╗
--		 ███████║██████╔╝██║  ██║█████╗  ██║     ██████╔╝██╔████╔██║██████╔╝
--		 ██╔══██║██╔══██╗██║  ██║██╔══╝  ██║     ██╔══██╗██║╚██╔╝██║██╔══██╗
--		 ██║  ██║██████╔╝██████╔╝███████╗███████╗██║  ██║██║ ╚═╝ ██║██████╔╝
--		 ╚═╝  ╚═╝╚═════╝ ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═════╝

ESX = exports["es_extended"]:getSharedObject()

local playerId = GetPlayerServerId(PlayerId())
local playerName = GetPlayerName(PlayerId())
local job = "Inconnu"
local cash = 0
local bank = 0
local dirtyMoney = 0

function fetchPlayerInfo(callback)
    ESX.TriggerServerCallback('f5menu:getPlayerInfo', function(user)
        if user then
            playerName = user.firstname .. " " .. user.lastname
            job = user.job .. " (" .. user.jobGrade .. ")"
            
            local accounts = user.accounts
            if accounts then
                cash = accounts.money or 0
                bank = accounts.bank or 0
                dirtyMoney = accounts.black_money or 0
            else
                cash, bank, dirtyMoney = 0, 0, 0
            end
        end
        
        if callback then callback() end
    end)
end

function fetchPlayerBills(callback)
    ESX.TriggerServerCallback('f5menu:getPlayerBills', function(billsData)
        bills = billsData or {}
        if callback then callback() end
    end)
end


exports['AbdelRMBUI']:CreateMenu("F5", "mainMenu", "")
exports['AbdelRMBUI']:CreateMenu("F5", "playerInfo", "Informations du Joueur", "mainMenu")
exports['AbdelRMBUI']:CreateMenu("F5", "playerMoney", "Portefeuille du Joueur", "mainMenu")
exports['AbdelRMBUI']:CreateMenu("F5", "playerBills", "Factures", "mainMenu")

exports['AbdelRMBUI']:AddMenuItem("F5_mainMenu", "Informations", function()
    fetchPlayerInfo()
    updatePlayerInfoMenu()
    exports['AbdelRMBUI']:OpenMenu("F5", "playerInfo")
end)

exports['AbdelRMBUI']:AddMenuItem("F5_mainMenu", "Portefeuille", function()
    fetchPlayerInfo()
    updatePlayerMoneyMenu()
    exports['AbdelRMBUI']:OpenMenu("F5", "playerMoney")
end)

exports['AbdelRMBUI']:AddMenuItem("F5_mainMenu", "Factures", function()
    fetchPlayerBills(function()
        updatePlayerBillsMenu()
        exports['AbdelRMBUI']:OpenMenu("F5", "playerBills")
    end)
end)

exports['AbdelRMBUI']:AddMenuItem("F5_mainMenu", "Quitter le menu", function()
    exports['AbdelRMBUI']:CloseMenu("F5", "mainMenu")
end)

function updatePlayerInfoMenu()
    exports['AbdelRMBUI']:ClearMenu("F5_playerInfo")
    exports['AbdelRMBUI']:AddMenuItem("F5_playerInfo", "Nom: " .. playerName)
    exports['AbdelRMBUI']:AddMenuItem("F5_playerInfo", "ID: " .. playerId)
    exports['AbdelRMBUI']:AddMenuItem("F5_playerInfo", "Job: " .. job)
    exports['AbdelRMBUI']:AddMenuItem("F5_playerInfo", "Retour au Menu Principal", function()
        exports['AbdelRMBUI']:OpenMenu("F5", "mainMenu")
    end)
end

function updatePlayerMoneyMenu()
    exports['AbdelRMBUI']:ClearMenu("F5_playerMoney")
    exports['AbdelRMBUI']:AddMenuItem("F5_playerMoney", "Espèces: $" .. cash)
    exports['AbdelRMBUI']:AddMenuItem("F5_playerMoney", "Banque: $" .. bank)
    exports['AbdelRMBUI']:AddMenuItem("F5_playerMoney", "Argent sale: $" .. dirtyMoney)
    exports['AbdelRMBUI']:AddMenuItem("F5_playerMoney", "Retour au Menu Principal", function()
        exports['AbdelRMBUI']:OpenMenu("F5", "mainMenu")
    end)
end


function updatePlayerBillsMenu()
    exports['AbdelRMBUI']:ClearMenu("F5_playerBills")

    if #bills > 0 then
        for _, bill in ipairs(bills) do
            local label = bill.label .. " - $" .. bill.amount
            exports['AbdelRMBUI']:AddMenuItem("F5_playerBills", label, function()
                TriggerServerEvent('f5menu:payBill', bill.id, bill.amount, bill.target)
                fetchPlayerBills(updatePlayerBillsMenu)
                exports['AbdelRMBUI']:CloseMenu("F5", "playerBills")
            end)
        end
    else
        exports['AbdelRMBUI']:AddMenuItem("F5_playerBills", "Aucune facture disponible.")
    end

    exports['AbdelRMBUI']:AddMenuItem("F5_playerBills", "Retour au Menu Principal", function()
        exports['AbdelRMBUI']:OpenMenu("F5", "mainMenu")
    end)
end



function openF5Menu()
    fetchPlayerInfo(function()
        updatePlayerInfoMenu()
        updatePlayerMoneyMenu()
        exports['AbdelRMBUI']:OpenMenu("F5", "mainMenu")
    end)
end

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(1, 166) then
            openF5Menu()
        end
    end
end)